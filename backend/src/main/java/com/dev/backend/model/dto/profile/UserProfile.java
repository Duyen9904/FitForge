package com.dev.backend.model.dto.profile;

import lombok.Builder;
import lombok.Value;

import java.util.List;

/**
 * Read-only view of the user's training and nutrition profile
 * derived from onboarding responses + core user fields.
 *
 * This DTO is intentionally decoupled from persistence entities
 * so it can evolve alongside recommendation algorithms without
 * forcing schema changes.
 */
@Value
@Builder
public class UserProfile {

    Long userId;

    // Core identity
    String gender;
    Integer ageYears;
    Float heightCm;
    Float currentWeightKg;
    Float targetWeightKg;

    // Training preferences and constraints
    String fitnessLevel;              // BEGINNER / INTERMEDIATE / ADVANCED
    String primaryGoalName;           // e.g. "Slimfit", "Athletic", "Bodybuilding"
    List<String> goalKeys;            // e.g. ["SLIMFIT", "ATHLETIC", "BODYBUILDING"]
    List<String> equipmentKeys;       // equipment option keys from onboarding
    List<String> scheduleDays;        // MON, WED, FRI
    Integer preferredSessionDuration; // minutes
    String preferredTimeOfDay;        // MORNING / EVENING etc.
    List<String> healthLimitations;   // e.g. ["LOWER_BACK_PAIN"]

    // Nutrition-related preferences
    Integer maintenanceCaloriesEstimate;
    Integer dailyCalorieTargetPreference;
    Float dailyProteinTargetGPreference;
    Float dailyCarbsTargetGPreference;
    Float dailyFatsTargetGPreference;

    // Notification / engagement preferences
    Boolean workoutRemindersEnabled;
}
