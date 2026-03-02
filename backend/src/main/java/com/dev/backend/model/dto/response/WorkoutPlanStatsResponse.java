package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Aggregate stats for a user's workout plans.
 * Used by the Workout Plans screen header to show at-a-glance metrics.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutPlanStatsResponse {

    /** Total number of workout plans owned by the user */
    private long totalPlans;

    /** Number of currently active plans */
    private long activePlans;

    /** Total number of completed workout sessions across all plans */
    private long completedWorkouts;

    /** Current consecutive-day workout streak */
    private int currentStreak;
}
