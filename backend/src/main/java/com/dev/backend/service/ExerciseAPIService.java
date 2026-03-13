package com.dev.backend.service;

import com.dev.backend.model.dto.external.ExerciseDBResponse;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.WorkoutPlan;

import java.util.List;

/**
 * Service for integrating with ExerciseDB API
 * Provides exercise recommendations with fallback to local database
 */
public interface ExerciseAPIService {

    /**
     * Select exercises for a workout plan based on goal, equipment, and difficulty
     * @param plan the workout plan
     * @return list of exercises suitable for the plan
     */
    List<Exercise> selectExercisesForPlan(WorkoutPlan plan);

    /**
     * Search exercises by muscle group (target)
     * Falls back to local database if API is unavailable
     * @param muscleGroup the target muscle group
     * @param limit number of exercises to return
     * @return list of exercises
     */
    List<Exercise> searchByMuscleGroup(String muscleGroup, int limit);

    /**
     * Search exercises by equipment
     * Falls back to local database if API is unavailable
     * @param equipment the equipment type
     * @param limit number of exercises to return
     * @return list of exercises
     */
    List<Exercise> searchByEquipment(String equipment, int limit);

    /**
     * Get or create exercise from API response
     * Caches exercises in local database for future use
     * @param exerciseId API exercise ID
     * @return Exercise entity (persisted or cached)
     */
    Exercise getOrCreateExercise(String exerciseId);

    /**
     * Persist an exercise from an already-fetched API response.
     * Checks local DB first; saves if new. No additional API call.
     * @param apiResponse the already-fetched API response
     * @return Exercise entity (existing or newly saved)
     */
    Exercise getOrCreateFromResponse(ExerciseDBResponse apiResponse);
}
