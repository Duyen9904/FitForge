package com.dev.backend.model.enums;

/**
 * Renderable input/selection type for onboarding steps.
 * Used by the frontend to choose the correct UI component (single choice, multiple choice, text, etc.).
 */
public enum OnboardingInputType {
    /** Free-text fields (e.g. name, DOB, gender) */
    TEXT,

    /** Numeric fields (e.g. weight, height) */
    NUMBER,

    /** One option from a list (radio / dropdown) */
    SINGLE_CHOICE,

    /** Multiple options (checkboxes / multi-select) */
    MULTIPLE_CHOICE,

    /** Boolean toggles per option (e.g. notifications) */
    TOGGLE
}
