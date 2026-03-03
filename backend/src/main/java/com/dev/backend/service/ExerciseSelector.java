package com.dev.backend.service;

import com.dev.backend.model.dto.ai.AiExerciseSlot;
import com.dev.backend.model.entity.Exercise;

import java.util.List;
import java.util.Set;

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
                            Set<Long> alreadyUsedIds);
}
