package com.dev.backend.model.enums;

/**
 * Types of onboarding steps that can be configured by admin.
 * Each type determines the input fields and validation for the step.
 */
public enum OnboardingStepType {
    /** Text inputs for name, DOB, gender */
    PERSONAL_INFO,
    
    /** Numeric inputs for weight, height */
    BODY_METRICS,

    /** Single select gender (Female / Male) */
    GENDER,

    /** Numeric input for age */
    AGE,

    /** Numeric input for weight (kg) */
    WEIGHT,

    /** Numeric input for height (cm) */
    HEIGHT,
    
    /** Single select from admin-configured fitness level options */
    FITNESS_LEVEL,
    
    /** Single/multi select from admin-configured fitness goal options */
    FITNESS_GOAL,
    
    /** Multi-select from admin-configured equipment options */
    EQUIPMENT,
    
    /** Multi-select days, select duration/time preferences */
    SCHEDULE,
    
    /** Multi-select from admin-configured health limitation options */
    HEALTH_LIMITATIONS,
    
    /** Toggle switches for each notification type */
    NOTIFICATIONS
}
