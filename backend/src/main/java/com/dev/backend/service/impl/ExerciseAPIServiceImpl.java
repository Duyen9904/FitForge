package com.dev.backend.service.impl;

import com.dev.backend.client.ExerciseAPIClient;
import com.dev.backend.model.dto.external.ExerciseDBResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.repository.EquipmentRepository;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.repository.MuscleGroupRepository;
import com.dev.backend.service.ExerciseAPIService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExerciseAPIServiceImpl implements ExerciseAPIService {

    private final ExerciseAPIClient exerciseAPIClient;
    private final ExerciseRepository exerciseRepository;
    private final MuscleGroupRepository muscleGroupRepository;
    private final EquipmentRepository equipmentRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Exercise> selectExercisesForPlan(WorkoutPlan plan) {
        log.info("Selecting exercises for plan: {}", plan.getPlanId());

        String targetMuscle = mapMuscleGroupToAPI(plan.getMuscleGroup().getGroupName());
        String goalType = plan.getGoal() != null ? plan.getGoal().getGoalName() : "GENERAL";
        String difficulty = plan.getDifficultyLevel();

        // Determine number of exercises needed per session
        int exercisesPerSession = calculateExercisesPerSession(goalType, difficulty);
        int totalExercisesNeeded = exercisesPerSession * 3; // For Day 1-3

        // Try to fetch from ExerciseDB API first
        List<Exercise> exercises = searchByMuscleGroup(targetMuscle, totalExercisesNeeded);

        // If not enough exercises, add compound movements
        if (exercises.size() < totalExercisesNeeded) {
            log.info("Not enough exercises for target muscle, adding compound movements");
            List<Exercise> compoundExercises = searchByBodyPart("upper body", totalExercisesNeeded - exercises.size());
            exercises.addAll(compoundExercises);
        }

        // Ensure we have at least minimum exercises, fallback to database if needed
        if (exercises.isEmpty()) {
            log.warn("No exercises from API, falling back to local database");
            exercises = fallbackToLocalDatabase(plan.getDifficultyLevel(), totalExercisesNeeded);
        }

        return exercises.stream()
                .limit(totalExercisesNeeded)
                .collect(Collectors.toList());
    }

    @Override
    @Cacheable(value = "exercises", key = "'muscle_' + #muscleGroup + '_' + #limit")
    @Transactional
    public List<Exercise> searchByMuscleGroup(String muscleGroup, int limit) {
        log.info("Searching exercises for muscle group: {}, limit: {}", muscleGroup, limit);

        // Local-first: check local DB (populated by sync worker)
        String category = inferMuscleCategory(muscleGroup);
        List<Exercise> localResults = exerciseRepository.findByMuscleGroupCategory(category);
        if (localResults.size() >= limit) {
            log.info("Found {} local exercises for '{}', using local data", localResults.size(), category);
            return localResults.stream().limit(limit).collect(Collectors.toList());
        }

        // If insufficient local data, try API (handles cold start / sparse categories)
        try {
            List<ExerciseDBResponse> apiResponses = exerciseAPIClient.searchByTarget(muscleGroup, limit);

            if (apiResponses == null || apiResponses.isEmpty()) {
                log.info("No results from ExerciseDB v2 API, using local database");
                return fallbackToLocalDatabaseByMuscle(muscleGroup, limit);
            }

            return apiResponses.stream()
                    .map(this::mapAndSaveExercise)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Error searching exercises by muscle group from API: {}", muscleGroup, e);
            return fallbackToLocalDatabaseByMuscle(muscleGroup, limit);
        }
    }

    @Override
    @Cacheable(value = "exercises", key = "'equipment_' + #equipment + '_' + #limit")
    @Transactional
    public List<Exercise> searchByEquipment(String equipment, int limit) {
        log.info("Searching exercises for equipment: {}, limit: {}", equipment, limit);

        // Local-first: check local DB
        List<Exercise> localResults = exerciseRepository.findByEquipmentCategoryIgnoreCase(equipment);
        if (localResults.size() >= limit) {
            log.info("Found {} local exercises for equipment '{}', using local data", localResults.size(), equipment);
            return localResults.stream().limit(limit).collect(Collectors.toList());
        }

        // If insufficient local data, try API
        try {
            List<ExerciseDBResponse> apiResponses = exerciseAPIClient.searchByEquipment(equipment, limit);

            if (apiResponses == null || apiResponses.isEmpty()) {
                log.info("No results from ExerciseDB v2 API, using local database");
                return fallbackToLocalDatabaseByEquipment(equipment, limit);
            }

            return apiResponses.stream()
                    .map(this::mapAndSaveExercise)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Error searching exercises by equipment from API: {}", equipment, e);
            return fallbackToLocalDatabaseByEquipment(equipment, limit);
        }
    }

    @Override
    @Cacheable(value = "exercises", key = "'api_' + #exerciseId")
    @Transactional
    public Exercise getOrCreateExercise(String exerciseId) {
        log.info("Getting or creating exercise from API ID: {}", exerciseId);

        // Check local DB first by exerciseId (PK)
        Optional<Exercise> existing = exerciseRepository.findById(exerciseId);
        if (existing.isPresent()) {
            return existing.get();
        }

        try {
            ExerciseDBResponse apiResponse = exerciseAPIClient.getExerciseById(exerciseId);

            if (apiResponse == null) {
                log.warn("Exercise not found in v2 API: {}", exerciseId);
                return null;
            }

            return mapAndSaveExercise(apiResponse);

        } catch (Exception e) {
            log.error("Error fetching exercise from v2 API: {}", exerciseId, e);
            return null;
        }
    }

    @Override
    @Transactional
    public Exercise getOrCreateFromResponse(ExerciseDBResponse apiResponse) {
        if (apiResponse == null || apiResponse.getExerciseId() == null) {
            return null;
        }

        return exerciseRepository.findById(apiResponse.getExerciseId())
                .orElseGet(() -> mapAndSaveExercise(apiResponse));
    }

    // ============= Mapping =============

    /**
     * Map v2 API response to Exercise entity and save.
     * Uses exerciseId as PK. Auto-creates MuscleGroup and Equipment rows.
     */
    private Exercise mapAndSaveExercise(ExerciseDBResponse apiResponse) {
        try {
            // Dedup by exerciseId (PK) instead of name
            String apiExerciseId = apiResponse.getExerciseId();
            if (apiExerciseId == null || apiExerciseId.isBlank()) {
                log.warn("Skipping exercise with null/blank exerciseId (name={}). " +
                         "Check ExerciseDBResponse @JsonProperty/@JsonAlias mapping.", apiResponse.getName());
                return null;
            }

            Optional<Exercise> existing = exerciseRepository.findById(apiExerciseId);
            if (existing.isPresent()) {
                return existing.get();
            }

            Exercise exercise = new Exercise();
            exercise.setExerciseId(apiExerciseId);
            exercise.setExerciseName(apiResponse.getName());
            exercise.setDescription(apiResponse.getOverview());
            exercise.setExerciseType(apiResponse.getExerciseType());
            exercise.setImageUrl(apiResponse.getImageUrl());
            exercise.setVideoUrl(apiResponse.getImageUrl()); // placeholder

            // Infer difficulty from equipment list
            String primaryEquipment = apiResponse.getEquipments() != null && !apiResponse.getEquipments().isEmpty()
                    ? apiResponse.getEquipments().get(0) : null;
            exercise.setDifficultyLevel(inferDifficulty(primaryEquipment));
            exercise.setEquipmentCategory(primaryEquipment);
            exercise.setRequiresSpotter(requiresSpotter(primaryEquipment));

            // Map instructions
            if (apiResponse.getInstructions() != null && !apiResponse.getInstructions().isEmpty()) {
                exercise.setInstructions(String.join("\n", apiResponse.getInstructions()));
            }

            // Map tips
            if (apiResponse.getExerciseTips() != null && !apiResponse.getExerciseTips().isEmpty()) {
                exercise.setTips(String.join("\n", apiResponse.getExerciseTips()));
            }

            // Estimate calories
            String primaryBodyPart = apiResponse.getBodyParts() != null && !apiResponse.getBodyParts().isEmpty()
                    ? apiResponse.getBodyParts().get(0) : null;
            exercise.setCaloriesBurnedPerMin(estimateCaloriesBurned(primaryBodyPart));

            // Save exercise first (so it has an ID for join tables)
            exercise = exerciseRepository.save(exercise);

            // Map targetMuscles → ExerciseMuscleGroup (isPrimary=true)
            if (apiResponse.getTargetMuscles() != null) {
                for (String muscleName : apiResponse.getTargetMuscles()) {
                    MuscleGroup muscleGroup = findOrCreateMuscleGroup(muscleName);
                    ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                    emg.setExercise(exercise);
                    emg.setMuscleGroup(muscleGroup);
                    emg.setIsPrimary(true);
                    exercise.getExerciseMuscleGroups().add(emg);
                }
            }

            // Map secondaryMuscles → ExerciseMuscleGroup (isPrimary=false)
            if (apiResponse.getSecondaryMuscles() != null) {
                for (String muscleName : apiResponse.getSecondaryMuscles()) {
                    MuscleGroup muscleGroup = findOrCreateMuscleGroup(muscleName);
                    ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                    emg.setExercise(exercise);
                    emg.setMuscleGroup(muscleGroup);
                    emg.setIsPrimary(false);
                    exercise.getExerciseMuscleGroups().add(emg);
                }
            }

            // Map equipments → ExerciseEquipment
            if (apiResponse.getEquipments() != null) {
                for (String equipName : apiResponse.getEquipments()) {
                    Equipment equipment = findOrCreateEquipment(equipName);
                    ExerciseEquipment ee = new ExerciseEquipment();
                    ee.setExercise(exercise);
                    ee.setEquipment(equipment);
                    ee.setIsRequired(true);
                    exercise.getExerciseEquipments().add(ee);
                }
            }

            // Save again with relationships
            return exerciseRepository.save(exercise);

        } catch (Exception e) {
            log.error("Error mapping and saving exercise: {}", apiResponse.getName(), e);
            return null;
        }
    }

    /**
     * Find existing MuscleGroup by name or create a new one (auto-seeding).
     */
    private MuscleGroup findOrCreateMuscleGroup(String muscleName) {
        return muscleGroupRepository.findByGroupName(muscleName)
                .orElseGet(() -> {
                    log.info("Auto-creating muscle group: {}", muscleName);
                    MuscleGroup mg = new MuscleGroup();
                    mg.setGroupName(muscleName);
                    mg.setCategory(inferMuscleCategory(muscleName));
                    return muscleGroupRepository.save(mg);
                });
    }

    /**
     * Find existing Equipment by name or create a new one (auto-seeding).
     */
    private Equipment findOrCreateEquipment(String equipmentName) {
        return equipmentRepository.findByEquipmentName(equipmentName)
                .orElseGet(() -> {
                    log.info("Auto-creating equipment: {}", equipmentName);
                    Equipment eq = new Equipment();
                    eq.setEquipmentName(equipmentName);
                    eq.setEquipmentType(inferEquipmentType(equipmentName));
                    return equipmentRepository.save(eq);
                });
    }

    // ============= Helper: Search by body part =============

    private List<Exercise> searchByBodyPart(String bodyPart, int limit) {
        try {
            List<ExerciseDBResponse> apiResponses = exerciseAPIClient.searchByBodyPart(bodyPart, limit);

            if (apiResponses == null || apiResponses.isEmpty()) {
                return List.of();
            }

            return apiResponses.stream()
                    .map(this::mapAndSaveExercise)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Error searching exercises by body part from API: {}", bodyPart, e);
            return List.of();
        }
    }

    // ============= Fallback to local DB =============

    private List<Exercise> fallbackToLocalDatabase(String difficultyLevel, int limit) {
        log.info("Falling back to local database for difficulty: {}, limit: {}", difficultyLevel, limit);

        List<Exercise> exercises = exerciseRepository.findByDifficultyLevel(difficultyLevel);

        if (exercises.isEmpty()) {
            exercises = exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
        }

        return exercises.stream()
                .limit(limit)
                .collect(Collectors.toList());
    }

    private List<Exercise> fallbackToLocalDatabaseByMuscle(String muscleGroup, int limit) {
        log.info("Falling back to local database for muscle group: {}", muscleGroup);
        // Use category-based lookup instead of unfiltered findAll
        String category = inferMuscleCategory(muscleGroup);
        List<Exercise> exercises = exerciseRepository.findByMuscleGroupCategory(category);
        if (exercises.isEmpty()) {
            log.debug("No local exercises for category '{}', falling back to paginated findAll", category);
            exercises = exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
        }
        return exercises.stream().limit(limit).collect(Collectors.toList());
    }

    private List<Exercise> fallbackToLocalDatabaseByEquipment(String equipment, int limit) {
        log.info("Falling back to local database for equipment: {}", equipment);
        // Use equipment category filter instead of unfiltered findAll
        List<Exercise> exercises = exerciseRepository.findByEquipmentCategoryIgnoreCase(equipment);
        if (exercises.isEmpty()) {
            log.debug("No local exercises for equipment '{}', falling back to paginated findAll", equipment);
            exercises = exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
        }
        return exercises.stream().limit(limit).collect(Collectors.toList());
    }

    // ============= Mapping Helpers =============

    private String mapMuscleGroupToAPI(String muscleGroup) {
        if (muscleGroup == null) return "pectorals";

        return switch (muscleGroup.toLowerCase()) {
            case "chest", "pecs" -> "pectorals";
            case "back" -> "lats";
            case "shoulders", "delts" -> "delts";
            case "biceps", "arms" -> "biceps";
            case "triceps" -> "triceps";
            case "legs", "quads" -> "quads";
            case "hamstrings" -> "hamstrings";
            case "glutes" -> "glutes";
            case "abs", "core" -> "abs";
            case "calves" -> "calves";
            default -> muscleGroup.toLowerCase();
        };
    }

    private int calculateExercisesPerSession(String goalType, String difficulty) {
        if (goalType.toUpperCase().contains("STRENGTH")) {
            return 4;
        } else if (goalType.toUpperCase().contains("MUSCLE") || goalType.toUpperCase().contains("GAIN")) {
            return 6;
        } else if (goalType.toUpperCase().contains("FAT") || goalType.toUpperCase().contains("LOSS")) {
            return 5;
        }
        return 5;
    }

    private String inferDifficulty(String equipment) {
        if (equipment == null) return "INTERMEDIATE";

        return switch (equipment.toLowerCase()) {
            case "body weight", "assisted" -> "BEGINNER";
            case "barbell", "smith machine" -> "ADVANCED";
            case "dumbbell", "cable", "resistance band" -> "INTERMEDIATE";
            default -> "INTERMEDIATE";
        };
    }

    private boolean requiresSpotter(String equipment) {
        if (equipment == null) return false;
        return equipment.equalsIgnoreCase("barbell") || equipment.equalsIgnoreCase("smith machine");
    }

    private int estimateCaloriesBurned(String bodyPart) {
        if (bodyPart == null) return 5;

        return switch (bodyPart.toLowerCase()) {
            case "cardio" -> 10;
            case "upper legs", "lower legs" -> 8;
            case "back", "chest" -> 7;
            case "shoulders", "upper arms", "lower arms" -> 5;
            default -> 6;
        };
    }

    private String inferMuscleCategory(String muscleName) {
        if (muscleName == null) return "OTHER";
        String lower = muscleName.toLowerCase();
        if (lower.contains("chest") || lower.contains("pec")) return "CHEST";
        if (lower.contains("lat") || lower.contains("back") || lower.contains("trap") || lower.contains("rhomboid")) return "BACK";
        if (lower.contains("delt") || lower.contains("shoulder")) return "SHOULDERS";
        if (lower.contains("bicep") || lower.contains("tricep") || lower.contains("forearm")) return "ARMS";
        if (lower.contains("quad") || lower.contains("hamstring") || lower.contains("glut") || lower.contains("calf")) return "LEGS";
        if (lower.contains("ab") || lower.contains("oblique") || lower.contains("core")) return "CORE";
        return "OTHER";
    }

    private String inferEquipmentType(String equipmentName) {
        if (equipmentName == null) return "OTHER";
        String lower = equipmentName.toLowerCase();
        if (lower.contains("barbell") || lower.contains("dumbbell") || lower.contains("kettlebell")) return "FREE_WEIGHT";
        if (lower.contains("machine") || lower.contains("cable") || lower.contains("smith")) return "MACHINE";
        if (lower.contains("band") || lower.contains("rope")) return "RESISTANCE";
        if (lower.contains("body weight") || lower.contains("bodyweight")) return "BODYWEIGHT";
        if (lower.contains("bench") || lower.contains("mat") || lower.contains("ball")) return "ACCESSORY";
        return "OTHER";
    }
}
