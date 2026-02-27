package com.dev.backend.model.enums;

/**
 * Types of compensation for cheat meals or missed workouts (UC-7.4)
 */
public enum CompensationType {
    ADD_CARDIO,       // Add cardio sessions to burn excess calories
    REDUCE_CALORIES,  // Reduce daily calories for a period
    COMBINATION,      // Combination of cardio and calorie reduction
    DO_NOTHING        // Accept the deviation, no compensation
}
