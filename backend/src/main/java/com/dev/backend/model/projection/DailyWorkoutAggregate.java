package com.dev.backend.model.projection;

import java.time.LocalDate;

/**
 * Projection for daily workout aggregates
 */
public interface DailyWorkoutAggregate {
    LocalDate getWorkoutDate();
    Long getTotalWorkouts();
    Long getTotalMinutes();
    Integer getTotalCalories();
}
