package com.dev.backend.service;

import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.Exercise;

/**
 * Service for recommending appropriate weights for exercises based on user profile,
 * fitness level, exercise type, and historical performance data.
 */
public interface WeightRecommendationService {

    /**
     * Recommend weight for a specific exercise for a user.
     * Uses historical data if available, otherwise estimates based on user profile.
     *
     * @param userId User ID
     * @param exerciseId Exercise ID
     * @param targetReps Target number of repetitions
     * @param goalType Goal type (e.g., "STRENGTH", "MUSCLE_GAIN", "FAT_LOSS")
     * @return Recommended weight in kg, or null if bodyweight exercise
     */
    Float recommendWeight(Long userId, Long exerciseId, Integer targetReps, String goalType);

    /**
     * Estimate starting weight for a new user or exercise without history.
     *
     * @param profile User profile containing fitness level, body weight, gender, etc.
     * @param exercise Exercise entity
     * @param targetReps Target number of repetitions
     * @return Estimated weight in kg, or null if bodyweight exercise
     */
    Float estimateStartingWeight(UserProfile profile, Exercise exercise, Integer targetReps);
}
