package com.dev.backend.model.dto.ai;

import com.dev.backend.model.dto.profile.UserProfile;
import lombok.Builder;
import lombok.Value;

import java.time.LocalDate;
import java.util.List;

/**
 * Context DTO encapsulating all inputs needed by AiService
 * to generate a workout plan.
 */
@Value
@Builder
public class AiPlanGenerationContext {
    UserProfile profile;
    List<String> availableEquipment;
    String additionalInformation;
    Integer frequencyPerWeek;
    Integer durationWeeks;
    String difficultyLevel;
    LocalDate startDate;
    String goalName;
    List<String> targetMuscleGroups;
    Integer weekNumber; // which week to generate (1-based), null = week 1
}
