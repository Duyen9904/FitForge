package com.dev.backend.model.dto.ai;

import com.dev.backend.model.dto.profile.UserProfile;
import lombok.Builder;
import lombok.Value;

import java.time.LocalDate;
import java.util.List;

/**
 * Context DTO for AI-powered plan adjustment based on behavior data.
 * Extends the generation context concept with behavioral metrics.
 */
@Value
@Builder
public class AiPlanAdjustmentContext {
    // User context
    UserProfile profile;
    List<String> availableEquipment;
    String goalName;
    List<String> targetMuscleGroups;

    // Current plan info
    String currentPlanName;
    String currentPlanDescription;
    Integer frequencyPerWeek;
    Integer durationWeeks;
    String difficultyLevel;
    LocalDate startDate;

    // Behavior metrics
    Float workoutAdherence;
    Float avgCompletionRate;
    Float avgRPE;
    Integer painFlagCount;
    String currentPlanSummary; // summary of current sessions for AI context
}
