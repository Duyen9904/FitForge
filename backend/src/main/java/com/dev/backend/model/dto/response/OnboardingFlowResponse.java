package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for complete onboarding flow.
 * Includes all steps with user's progress status.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OnboardingFlowResponse {

    /** Total number of steps in the onboarding flow */
    private Integer totalSteps;
    
    /** Number of steps the user has completed */
    private Integer completedSteps;
    
    /** Index of the current step (0-indexed) - FE can use this to navigate directly */
    private Integer currentStepIndex;
    
    /** Whether the user has completed all required steps */
    private Boolean isComplete;
    
    /** All onboarding steps with their status and options */
    private List<OnboardingStepResponse> steps;
}
