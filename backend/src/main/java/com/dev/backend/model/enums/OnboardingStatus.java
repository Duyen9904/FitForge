package com.dev.backend.model.enums;

/**
 * Status of a user's overall onboarding session.
 */
public enum OnboardingStatus {
    /** User has started onboarding and is progressing through steps */
    IN_PROGRESS,

    /** User has completed all required onboarding steps */
    COMPLETED,

    /** User abandoned or reset this onboarding session */
    ABANDONED
}
