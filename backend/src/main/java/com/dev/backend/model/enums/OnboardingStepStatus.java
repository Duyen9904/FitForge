package com.dev.backend.model.enums;

/**
 * Status of a user's progress on an onboarding step.
 */
public enum OnboardingStepStatus {
    /** Step has not been completed yet */
    PENDING,
    
    /** User has completed the step */
    COMPLETED,
    
    /** User has skipped this optional step */
    SKIPPED
}
