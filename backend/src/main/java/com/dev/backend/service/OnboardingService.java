package com.dev.backend.service;

import com.dev.backend.model.dto.request.SubmitOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingProgressResponse;

/**
 * Service for user-facing onboarding operations (UC-17).
 */
public interface OnboardingService {

    /**
     * Get the complete onboarding flow for a user.
     * Includes all active steps with user's progress status.
     * UC-17.1
     */
    OnboardingFlowResponse getOnboardingFlow(Long userId);

    /**
     * Submit user's response for an onboarding step.
     * UC-17.2 to UC-17.9
     */
    OnboardingProgressResponse submitStepResponse(Long userId, Long stepId, SubmitOnboardingStepRequest request);

    /**
     * Skip an optional onboarding step.
     * UC-17.10
     */
    OnboardingProgressResponse skipStep(Long userId, Long stepId);

    /**
     * Mark onboarding as complete after all required steps are done.
     * UC-17.13
     */
    void completeOnboarding(Long userId);

    /**
     * Check if a user has completed onboarding.
     */
    boolean isOnboardingComplete(Long userId);
}
