package com.dev.backend.model.enums;

/**
 * Determines which generation strategy to use for on-demand session creation.
 */
public enum PlanGenerationStrategy {
    MANUAL,      // User-created sessions only; no auto-generation
    AI,          // Use AiService for on-demand session generation
    RULE_BASED   // Use existing WorkoutSessionGenerator (template-based)
}
