package com.dev.backend.service.impl;

import com.dev.backend.client.ExerciseAPIClient;
import com.dev.backend.model.dto.external.ExerciseDBResponse;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.repository.ExerciseRepository;
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

        try {
            // Try ExerciseDB API first
            List<ExerciseDBResponse> apiResponses = exerciseAPIClient.searchByTarget(muscleGroup, limit);

            if (apiResponses == null || apiResponses.isEmpty()) {
                log.info("No results from ExerciseDB API, falling back to local database");
                return fallbackToLocalDatabaseByMuscle(muscleGroup, limit);
            }

            // Convert API responses to Exercise entities and save to database
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

        try {
            // Try ExerciseDB API first
            List<ExerciseDBResponse> apiResponses = exerciseAPIClient.searchByEquipment(equipment, limit);

            if (apiResponses == null || apiResponses.isEmpty()) {
                log.info("No results from ExerciseDB API, falling back to local database");
                return fallbackToLocalDatabaseByEquipment(equipment, limit);
            }

            // Convert API responses to Exercise entities and save to database
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

        try {
            // Try to fetch from ExerciseDB API
            ExerciseDBResponse apiResponse = exerciseAPIClient.getExerciseById(exerciseId);

            if (apiResponse == null) {
                log.warn("Exercise not found in API: {}", exerciseId);
                return null;
            }

            return mapAndSaveExercise(apiResponse);

        } catch (Exception e) {
            log.error("Error fetching exercise from API: {}", exerciseId, e);
            return null;
        }
    }

    // Helper: Search by body part (fallback method)
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

    // Helper: Map ExerciseDB response to Exercise entity and save
    private Exercise mapAndSaveExercise(ExerciseDBResponse apiResponse) {
        try {
            // Check if exercise already exists by name
            Optional<Exercise> existing = exerciseRepository.findByExerciseName(apiResponse.getName());
            if (existing.isPresent()) {
                return existing.get();
            }

            // Create new exercise
            Exercise exercise = new Exercise();
            exercise.setExerciseName(apiResponse.getName());
            exercise.setDescription("Target: " + apiResponse.getTarget() + ", Equipment: " + apiResponse.getEquipment());
            exercise.setDifficultyLevel(inferDifficulty(apiResponse.getEquipment()));
            exercise.setExerciseType(apiResponse.getBodyPart());
            exercise.setImageUrl(apiResponse.getGifUrl());
            exercise.setVideoUrl(apiResponse.getGifUrl()); // Using GIF as video placeholder
            exercise.setEquipmentCategory(apiResponse.getEquipment());
            exercise.setRequiresSpotter(requiresSpotter(apiResponse.getEquipment()));

            // Build instructions from API
            if (apiResponse.getInstructions() != null && apiResponse.getInstructions().length > 0) {
                exercise.setInstructions(String.join("\n", apiResponse.getInstructions()));
            }

            // Estimate calories burned (rough estimate)
            exercise.setCaloriesBurnedPerMin(estimateCaloriesBurned(apiResponse.getBodyPart()));

            return exerciseRepository.save(exercise);

        } catch (Exception e) {
            log.error("Error mapping and saving exercise: {}", apiResponse.getName(), e);
            return null;
        }
    }

    // Helper: Fallback to local database
    private List<Exercise> fallbackToLocalDatabase(String difficultyLevel, int limit) {
        log.info("Falling back to local database for difficulty: {}, limit: {}", difficultyLevel, limit);
        
        List<Exercise> exercises = exerciseRepository.findByDifficultyLevel(difficultyLevel);
        
        if (exercises.isEmpty()) {
            // If no exercises for specific difficulty, get any exercises
            exercises = exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
        }
        
        return exercises.stream()
                .limit(limit)
                .collect(Collectors.toList());
    }

    private List<Exercise> fallbackToLocalDatabaseByMuscle(String muscleGroup, int limit) {
        log.info("Falling back to local database for muscle group: {}", muscleGroup);
        // For now, return general exercises - in production, implement muscle group filtering
        return exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
    }

    private List<Exercise> fallbackToLocalDatabaseByEquipment(String equipment, int limit) {
        log.info("Falling back to local database for equipment: {}", equipment);
        // For now, return general exercises - in production, implement equipment filtering
        return exerciseRepository.findAll(PageRequest.of(0, limit)).getContent();
    }

    // Helper: Map muscle group names to ExerciseDB API format
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
            default -> "pectorals";
        };
    }

    // Helper: Calculate exercises per session based on goal and difficulty
    private int calculateExercisesPerSession(String goalType, String difficulty) {
        if (goalType.toUpperCase().contains("STRENGTH")) {
            return 4; // Fewer exercises, more focus
        } else if (goalType.toUpperCase().contains("MUSCLE") || goalType.toUpperCase().contains("GAIN")) {
            return 6; // More volume
        } else if (goalType.toUpperCase().contains("FAT") || goalType.toUpperCase().contains("LOSS")) {
            return 5; // Circuit style
        }
        return 5; // Default
    }

    // Helper: Infer difficulty from equipment
    private String inferDifficulty(String equipment) {
        if (equipment == null) return "INTERMEDIATE";
        
        return switch (equipment.toLowerCase()) {
            case "body weight", "assisted" -> "BEGINNER";
            case "barbell", "smith machine" -> "ADVANCED";
            case "dumbbell", "cable", "resistance band" -> "INTERMEDIATE";
            default -> "INTERMEDIATE";
        };
    }

    // Helper: Determine if exercise requires spotter
    private boolean requiresSpotter(String equipment) {
        if (equipment == null) return false;
        return equipment.equalsIgnoreCase("barbell") || equipment.equalsIgnoreCase("smith machine");
    }

    // Helper: Estimate calories burned per minute
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
}
