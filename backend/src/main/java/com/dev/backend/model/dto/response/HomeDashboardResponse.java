package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Aggregated response DTO for the home dashboard endpoint.
 * Combines today's session, weekly stats, weekly progress chart, and active plans.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class HomeDashboardResponse {

    /** Today's scheduled workout session (null if rest day or no active plan) */
    private TodaySessionInfo todaySession;

    /** Aggregated stats for the current week */
    private WeeklyQuickStats weeklyStats;

    /** Full weekly progress for the bar chart (reuses existing DTO) */
    private WeeklyWorkoutProgressResponse weeklyProgress;

    /** User's active workout plans (summary level) */
    private List<ActivePlanInfo> activePlans;

    // ====== Inner DTOs ======

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TodaySessionInfo {
        private Long planId;
        private Long sessionId;
        private String planName;
        private String sessionName;
        private Integer exerciseCount;
        private Integer estimatedMinutes;
        private LocalDate scheduledDate;
        /** Target muscle groups for this session, e.g. ["CHEST", "SHOULDERS"] */
        private List<String> targetMuscleGroups;
        /** Whether this session has already been completed today */
        private Boolean alreadyCompleted;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklyQuickStats {
        /** Total calories burned this week */
        private Integer caloriesBurned;
        /** Number of workouts completed this week */
        private Integer workoutsCompleted;
        /** Number of workouts planned for this week */
        private Integer workoutsPlanned;
        /** Total exercise time this week in minutes */
        private Integer totalMinutes;
        /** Current workout streak in days */
        private Integer currentStreak;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ActivePlanInfo {
        private Long planId;
        private String planName;
        private Integer frequencyPerWeek;
        private Integer durationWeeks;
        /** Which week the user is currently on (1-based) */
        private Integer currentWeek;
        /** Total sessions completed out of all sessions in the plan */
        private Integer sessionsCompleted;
        private Integer totalSessions;
        private Boolean isActive;
    }
}
