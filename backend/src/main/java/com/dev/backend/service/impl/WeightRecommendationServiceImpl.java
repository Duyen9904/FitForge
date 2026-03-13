package com.dev.backend.service.impl;

import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.repository.ExerciseLogRepository;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.service.UserProfileService;
import com.dev.backend.service.WeightRecommendationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Implementation of weight recommendation service.
 * Calculates appropriate weights based on user profile, exercise type, and historical data.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WeightRecommendationServiceImpl implements WeightRecommendationService {

    private final ExerciseLogRepository exerciseLogRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserProfileService userProfileService;

    @Override
    public Float recommendWeight(Long userId, String exerciseId, Integer targetReps, String goalType) {
        // Get user profile
        UserProfile profile = userProfileService.buildProfile(userId);
        
        // Get exercise
        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElse(null);
        
        if (exercise == null) {
            log.warn("Exercise not found: {}", exerciseId);
            return null;
        }

        // Check if bodyweight exercise
        if (isBodyweightExercise(exercise)) {
            return null; // No weight needed for bodyweight exercises
        }

        // Try to get historical max weight
        Float maxWeight = exerciseLogRepository.findMaxWeightByUserAndExercise(userId, exerciseId);
        
        if (maxWeight != null && maxWeight > 0) {
            // User has history with this exercise - calculate based on 1RM
            return calculateWeightFromHistory(maxWeight, targetReps, goalType);
        } else {
            // New exercise for user - estimate based on profile
            return estimateStartingWeight(profile, exercise, targetReps);
        }
    }

    @Override
    public Float estimateStartingWeight(UserProfile profile, Exercise exercise, Integer targetReps) {
        // Check if bodyweight exercise
        if (isBodyweightExercise(exercise)) {
            return null;
        }

        // Get user's body weight
        Float bodyWeight = profile.getCurrentWeightKg();
        if (bodyWeight == null || bodyWeight <= 0) {
            log.warn("Invalid body weight for user: {}", profile.getUserId());
            return 10.0f; // Default minimum weight
        }

        // Determine base percentage based on exercise type
        float basePercentage = getBasePercentageForExercise(exercise);

        // Adjust for fitness level
        float fitnessMultiplier = getFitnessLevelMultiplier(profile.getFitnessLevel());

        // Adjust for gender
        float genderMultiplier = getGenderMultiplier(profile.getGender());

        // Adjust for target reps (higher reps = lower weight)
        float repsMultiplier = getRepsMultiplier(targetReps);

        // Calculate base weight
        float calculatedWeight = bodyWeight * basePercentage * fitnessMultiplier * genderMultiplier * repsMultiplier;

        // Round to nearest 2.5kg
        return roundToNearest2_5(calculatedWeight);
    }

    /**
     * Calculate working weight based on historical max weight
     */
    private Float calculateWeightFromHistory(Float maxWeight, Integer targetReps, String goalType) {
        // Estimate 1RM if the max weight wasn't for 1 rep
        // For simplicity, we'll assume maxWeight is close to their working max
        
        float percentage;
        
        // Determine percentage based on goal type and target reps
        if (goalType != null && goalType.toUpperCase().contains("STRENGTH")) {
            // Strength training: 85-90% of max
            percentage = 0.875f;
        } else if (goalType != null && (goalType.toUpperCase().contains("MUSCLE") || 
                                        goalType.toUpperCase().contains("HYPERTROPHY") ||
                                        goalType.toUpperCase().contains("GAIN"))) {
            // Hypertrophy: 70-80% of max
            percentage = 0.75f;
        } else if (goalType != null && (goalType.toUpperCase().contains("ENDURANCE") || 
                                        goalType.toUpperCase().contains("FAT"))) {
            // Endurance/Fat loss: 50-60% of max
            percentage = 0.55f;
        } else {
            // Default: moderate weight
            percentage = 0.70f;
        }

        // Adjust percentage based on target reps
        if (targetReps != null) {
            if (targetReps <= 5) {
                percentage += 0.05f; // Higher weight for low reps
            } else if (targetReps >= 15) {
                percentage -= 0.05f; // Lower weight for high reps
            }
        }

        // Ensure percentage is within reasonable bounds
        percentage = Math.max(0.5f, Math.min(0.95f, percentage));

        float calculatedWeight = maxWeight * percentage;

        // Add progressive overload (2.5-5kg increase)
        // Only add if the calculated weight is close to their max
        if (percentage > 0.80f && calculatedWeight < maxWeight) {
            calculatedWeight += 2.5f;
        }

        return roundToNearest2_5(calculatedWeight);
    }

    /**
     * Determine if exercise is bodyweight only
     */
    private boolean isBodyweightExercise(Exercise exercise) {
        if (exercise.getEquipmentCategory() == null) {
            return false;
        }
        
        String category = exercise.getEquipmentCategory().toUpperCase();
        return category.contains("BODYWEIGHT") || category.equals("NONE");
    }

    /**
     * Get base percentage of body weight for exercise type
     */
    private float getBasePercentageForExercise(Exercise exercise) {
        String exerciseName = exercise.getExerciseName().toLowerCase();

        // Compound lower body exercises
        if (exerciseName.contains("squat") || exerciseName.contains("deadlift") || 
            exerciseName.contains("leg press")) {
            return 0.50f; // 50% of body weight
        }

        // Compound upper body exercises
        if (exerciseName.contains("bench press") || exerciseName.contains("overhead press") ||
            exerciseName.contains("shoulder press")) {
            return 0.35f; // 35% of body weight
        }

        // Rowing movements
        if (exerciseName.contains("row") || exerciseName.contains("pull")) {
            return 0.30f; // 30% of body weight
        }

        // Lower body isolation
        if (exerciseName.contains("leg curl") || exerciseName.contains("leg extension") ||
            exerciseName.contains("calf")) {
            return 0.25f; // 25% of body weight
        }

        // Upper body isolation
        if (exerciseName.contains("curl") || exerciseName.contains("extension") ||
            exerciseName.contains("fly") || exerciseName.contains("raise") ||
            exerciseName.contains("lateral")) {
            return 0.12f; // 12% of body weight
        }

        // Default for unknown exercises
        return 0.20f; // 20% of body weight
    }

    /**
     * Get multiplier based on fitness level
     */
    private float getFitnessLevelMultiplier(String fitnessLevel) {
        if (fitnessLevel == null) {
            return 1.0f;
        }

        switch (fitnessLevel.toUpperCase()) {
            case "BEGINNER":
                return 0.7f; // Use lower end of range
            case "INTERMEDIATE":
                return 1.0f; // Use middle of range
            case "ADVANCED":
                return 1.3f; // Use upper end of range
            default:
                return 1.0f;
        }
    }

    /**
     * Get multiplier based on gender
     */
    private float getGenderMultiplier(String gender) {
        if (gender == null) {
            return 1.0f;
        }

        // Males typically start with 30-40% higher weights
        if (gender.equalsIgnoreCase("MALE") || gender.equalsIgnoreCase("M")) {
            return 1.0f;
        } else if (gender.equalsIgnoreCase("FEMALE") || gender.equalsIgnoreCase("F")) {
            return 0.65f; // Females typically start with 65% of male weights
        }

        return 1.0f; // Default
    }

    /**
     * Get multiplier based on target reps
     */
    private float getRepsMultiplier(Integer targetReps) {
        if (targetReps == null) {
            return 1.0f;
        }

        // Higher reps = lower weight
        if (targetReps <= 5) {
            return 1.1f; // Strength range - slightly higher weight
        } else if (targetReps <= 12) {
            return 1.0f; // Hypertrophy range - base weight
        } else if (targetReps <= 20) {
            return 0.8f; // Endurance range - lower weight
        } else {
            return 0.6f; // Very high reps - much lower weight
        }
    }

    /**
     * Round weight to nearest 2.5kg increment
     */
    private Float roundToNearest2_5(float weight) {
        if (weight < 2.5f) {
            return 2.5f; // Minimum weight
        }

        // Round to nearest 2.5kg
        float rounded = Math.round(weight / 2.5f) * 2.5f;

        // Cap at reasonable maximum
        return Math.min(rounded, 500.0f);
    }
}
