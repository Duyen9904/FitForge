package com.dev.backend.service;

import com.dev.backend.model.dto.request.ReorderOnboardingStepsRequest;
import com.dev.backend.model.dto.request.SaveOnboardingOptionRequest;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingAnalyticsResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;

import java.time.LocalDate;
import java.util.List;

/**
 * Service for admin onboarding configuration operations (UC-18).
 */
public interface OnboardingAdminService {

    // ============= Step Management (UC-18.1, UC-18.2, UC-18.3) =============

    /**
     * Get all onboarding steps for admin configuration.
     * UC-18.1
     */
    List<OnboardingStepResponse> getAllSteps();

    /**
     * Create a new onboarding step.
     * UC-18.2
     */
    OnboardingStepResponse createStep(SaveOnboardingStepRequest request);

    /**
     * Update an existing onboarding step.
     * UC-18.3
     */
    OnboardingStepResponse updateStep(Long stepId, SaveOnboardingStepRequest request);

    /**
     * Delete an onboarding step.
     * UC-18.2
     */
    void deleteStep(Long stepId);

    /**
     * Reorder onboarding steps.
     * UC-18.2
     */
    void reorderSteps(ReorderOnboardingStepsRequest request);

    // ============= Option Management (UC-18.4 to UC-18.8) =============

    /**
     * Create a new option for a step.
     * UC-18.4
     */
    OnboardingOptionResponse createOption(Long stepId, SaveOnboardingOptionRequest request);

    /**
     * Update an existing option.
     * UC-18.4
     */
    OnboardingOptionResponse updateOption(Long optionId, SaveOnboardingOptionRequest request);

    /**
     * Delete an option.
     * UC-18.4
     */
    void deleteOption(Long optionId);

    // ============= Analytics (UC-18.9) =============

    /**
     * Get onboarding analytics for a date range.
     * UC-18.9
     */
    OnboardingAnalyticsResponse getOnboardingAnalytics(LocalDate from, LocalDate to);
}
