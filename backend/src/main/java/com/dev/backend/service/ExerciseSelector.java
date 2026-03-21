package com.dev.backend.service;

import com.dev.backend.model.dto.ai.AiExerciseSlot;
import com.dev.backend.model.entity.Exercise;

import java.util.*;

/**
 * Selects real exercises from the database to fill AI-generated exercise slots.
 * This separates the AI (reasoning engine) from the exercise database (data store).
 */
public interface ExerciseSelector {

    /**
     * Select a real exercise from the database that best matches the given slot criteria.
     *
     * @param slot              the AI-generated exercise slot (muscle group, movement pattern, etc.)
     * @param availableEquipment user's available equipment categories (e.g. "FREE_WEIGHTS", "MACHINE")
     * @param difficultyLevel   user's fitness level (e.g. "BEGINNER", "INTERMEDIATE", "ADVANCED")
     * @param alreadyUsedIds    exercise IDs already used in this plan (to avoid duplicates)
     * @return the best matching exercise, or null if none found
     */
    Exercise selectExercise(AiExerciseSlot slot,
                            List<String> availableEquipment,
                            String difficultyLevel,
                            Set<String> alreadyUsedIds);

    /**
     * Select exercises for multiple slots using batch-loaded data.
     * More efficient than calling selectExercise() per slot — reduces N+1 queries
     * by loading all needed muscle group categories in a single pass.
     *
     * @param slots             all AI-generated exercise slots to fill
     * @param availableEquipment user's available equipment categories
     * @param difficultyLevel   user's fitness level
     * @return list of selected exercises (may be smaller than slots if some couldn't be filled)
     */
    default List<Exercise> selectExercisesForSlots(
            List<AiExerciseSlot> slots,
            List<String> availableEquipment,
            String difficultyLevel) {
        Set<String> usedIds = new HashSet<>();
        List<Exercise> results = new ArrayList<>();
        for (AiExerciseSlot slot : slots) {
            Exercise ex = selectExercise(slot, availableEquipment, difficultyLevel, usedIds);
            if (ex != null) {
                results.add(ex);
                usedIds.add(ex.getExerciseId());
            }
        }
        return results;
    }
}
