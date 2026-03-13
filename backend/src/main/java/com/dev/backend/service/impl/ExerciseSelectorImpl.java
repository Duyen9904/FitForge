package com.dev.backend.service.impl;

import com.dev.backend.model.dto.ai.AiExerciseSlot;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.service.ExerciseSelector;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Selects real exercises from the database to fill AI-generated exercise slots.
 * <p>
 * Selection logic:
 * 1. Query exercises by the slot's muscle group category
 * 2. Filter by user's available equipment
 * 3. Filter by difficulty level (if available)
 * 4. Prefer compound/isolation based on slot's movement pattern
 * 5. Exclude already-used exercises (no duplicates in plan)
 * 6. Pick a random exercise from top candidates for variety
 */
@Service
@Slf4j
public class ExerciseSelectorImpl implements ExerciseSelector {

    private static final Random RANDOM = new Random();

    /**
     * Equipment categories that map to common user equipment keys.
     * Used to match user equipment preferences to exercise equipment categories.
     */
    private static final Map<String, List<String>> EQUIPMENT_MAPPING = Map.of(
            "FREE_WEIGHTS", List.of("FREE_WEIGHTS", "BARBELL", "DUMBBELL", "KETTLEBELL"),
            "MACHINE", List.of("MACHINE", "CABLE"),
            "BODYWEIGHT", List.of("BODYWEIGHT", "BODY_WEIGHT", "BODY WEIGHT"),
            "ACCESSORIES", List.of("ACCESSORIES", "BAND", "RESISTANCE_BAND")
    );

    private final ExerciseRepository exerciseRepository;

    public ExerciseSelectorImpl(ExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    @Override
    public Exercise selectExercise(AiExerciseSlot slot,
                                   List<String> availableEquipment,
                                   String difficultyLevel,
                                   Set<String> alreadyUsedIds) {
        if (slot == null || slot.getMuscleGroup() == null) {
            log.warn("[ExerciseSelector] Null slot or muscle group, cannot select exercise");
            return null;
        }

        String muscleGroup = slot.getMuscleGroup().toUpperCase().trim();
        log.debug("[ExerciseSelector] Selecting exercise for muscle group: {}, pattern: {}, difficulty: {}",
                muscleGroup, slot.getMovementPattern(), difficultyLevel);

        // Step 1: Get all exercises for this muscle group
        List<Exercise> candidates = exerciseRepository.findByMuscleGroupCategory(muscleGroup);
        if (candidates == null || candidates.isEmpty()) {
            log.warn("[ExerciseSelector] No exercises found for muscle group: {}", muscleGroup);
            return null;
        }

        // Step 2: Filter out already-used exercises
        if (alreadyUsedIds != null && !alreadyUsedIds.isEmpty()) {
            candidates = candidates.stream()
                    .filter(ex -> !alreadyUsedIds.contains(ex.getExerciseId()))
                    .collect(Collectors.toList());
        }

        if (candidates.isEmpty()) {
            log.warn("[ExerciseSelector] All exercises for {} already used in plan", muscleGroup);
            // Fallback: allow duplicates rather than skipping
            candidates = exerciseRepository.findByMuscleGroupCategory(muscleGroup);
        }

        // Step 3: Filter by equipment
        List<Exercise> equipmentFiltered = filterByEquipment(candidates, availableEquipment);
        if (!equipmentFiltered.isEmpty()) {
            candidates = equipmentFiltered;
        } else {
            log.debug("[ExerciseSelector] No exercises match equipment filter, using all candidates");
        }

        // Step 4: Filter by difficulty level
        List<Exercise> difficultyFiltered = filterByDifficulty(candidates, difficultyLevel);
        if (!difficultyFiltered.isEmpty()) {
            candidates = difficultyFiltered;
        } else {
            log.debug("[ExerciseSelector] No exercises match difficulty filter, using all candidates");
        }

        // Step 5: Prefer compound/isolation based on movement pattern
        List<Exercise> patternFiltered = filterByMovementPattern(candidates, slot.getMovementPattern());
        if (!patternFiltered.isEmpty()) {
            candidates = patternFiltered;
        }

        // Step 6: Pick a random exercise from remaining candidates for variety
        Exercise selected = candidates.get(RANDOM.nextInt(candidates.size()));
        log.info("[ExerciseSelector] Selected: '{}' (ID: {}) for {} {}",
                selected.getExerciseName(), selected.getExerciseId(),
                muscleGroup, slot.getMovementPattern() != null ? slot.getMovementPattern() : "");

        return selected;
    }

    /**
     * Filter exercises by user's available equipment.
     */
    private List<Exercise> filterByEquipment(List<Exercise> exercises, List<String> availableEquipment) {
        if (availableEquipment == null || availableEquipment.isEmpty()) {
            return exercises;
        }

        // Build a set of all acceptable equipment category values
        Set<String> acceptableCategories = new HashSet<>();
        for (String userEquip : availableEquipment) {
            String key = userEquip.toUpperCase().trim();
            // Check if it maps to known categories
            List<String> mapped = EQUIPMENT_MAPPING.get(key);
            if (mapped != null) {
                for (String m : mapped) {
                    acceptableCategories.add(m.toUpperCase());
                }
            } else {
                // Add as-is (user might specify exact category names)
                acceptableCategories.add(key);
            }
        }
        // Always allow bodyweight exercises
        acceptableCategories.add("BODYWEIGHT");
        acceptableCategories.add("BODY_WEIGHT");
        acceptableCategories.add("BODY WEIGHT");

        return exercises.stream()
                .filter(ex -> {
                    String eqCat = ex.getEquipmentCategory();
                    if (eqCat == null || eqCat.isBlank()) return true; // no equipment = bodyweight
                    return acceptableCategories.contains(eqCat.toUpperCase().trim());
                })
                .collect(Collectors.toList());
    }

    /**
     * Filter exercises by difficulty level.
     * Beginners get beginner exercises, intermediates get beginner+intermediate, etc.
     */
    private List<Exercise> filterByDifficulty(List<Exercise> exercises, String difficultyLevel) {
        if (difficultyLevel == null || difficultyLevel.isBlank()) {
            return exercises;
        }

        Set<String> acceptableLevels = new HashSet<>();
        switch (difficultyLevel.toUpperCase()) {
            case "BEGINNER":
                acceptableLevels.add("BEGINNER");
                acceptableLevels.add("EASY");
                break;
            case "INTERMEDIATE":
                acceptableLevels.add("BEGINNER");
                acceptableLevels.add("EASY");
                acceptableLevels.add("INTERMEDIATE");
                acceptableLevels.add("MEDIUM");
                break;
            case "ADVANCED":
                // Advanced users can do all exercises
                return exercises;
            default:
                return exercises;
        }

        return exercises.stream()
                .filter(ex -> {
                    String dl = ex.getDifficultyLevel();
                    if (dl == null || dl.isBlank()) return true; // no difficulty = available to all
                    return acceptableLevels.contains(dl.toUpperCase().trim());
                })
                .collect(Collectors.toList());
    }

    /**
     * Filter by movement pattern: "compound" prefers compound exercises,
     * "isolation" prefers isolation exercises.
     */
    private List<Exercise> filterByMovementPattern(List<Exercise> exercises, String movementPattern) {
        if (movementPattern == null || movementPattern.isBlank()) {
            return exercises;
        }

        String pattern = movementPattern.toUpperCase().trim();
        return exercises.stream()
                .filter(ex -> {
                    String type = ex.getExerciseType();
                    if (type == null || type.isBlank()) return false;
                    return type.toUpperCase().trim().contains(pattern);
                })
                .collect(Collectors.toList());
    }
}
