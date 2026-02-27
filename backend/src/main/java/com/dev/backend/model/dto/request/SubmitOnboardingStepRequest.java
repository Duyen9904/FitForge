package com.dev.backend.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for user submitting a response to an onboarding step.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubmitOnboardingStepRequest {

    /**
     * JSON data containing the user's response for this step.
     * Use the step's inputType from GET /flow to know how to format this (TEXT, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, TOGGLE).
     * The structure depends on the step type:
     * - PERSONAL_INFO: {"name": "...", "dateOfBirth": "...", "gender": "..."}
     * - BODY_METRICS: {"weight": 70.5, "height": 175, "targetWeight": 68}
     * - FITNESS_LEVEL: {"selectedOption": "INTERMEDIATE"}
     * - FITNESS_GOAL: {"selectedOptions": ["BUILD_MUSCLE", "LOSE_FAT"]}
     * - EQUIPMENT: {"selectedOptions": ["DUMBBELLS", "BARBELL", "PULL_UP_BAR"]}
     * - SCHEDULE: {"days": ["MON", "WED", "FRI"], "duration": 60, "timeOfDay": "MORNING"}
     * - HEALTH_LIMITATIONS: {"selectedOptions": ["LOWER_BACK_PAIN"]}
     * - NOTIFICATIONS: {"workoutReminders": true, "achievementAlerts": true}
     */
    private String responseData;
}
