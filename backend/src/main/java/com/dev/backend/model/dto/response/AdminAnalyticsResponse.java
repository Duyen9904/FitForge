package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * DTO for admin analytics dashboard (UC-16.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminAnalyticsResponse {

    // User Statistics
    private Long totalUsers;
    private Long activeUsersLast30Days;
    private Long newUsersThisMonth;

    // Workout Statistics
    private Double averageWorkoutsPerUser;
    private Long totalWorkoutsCompleted;
    private Double averageAdherenceRatePercent;

    // Popular Content
    private List<PopularItem> mostPopularExercises;
    private List<PopularItem> mostPopularGoals;

    // Nutrition Statistics
    private Long totalCheatMealsLogged;
    private Double averageCheatMealsPerWeek;

    // Missed Workout Patterns
    private Map<String, Long> missedWorkoutReasons;
    private Long totalMissedWorkouts;

    // Feature Usage
    private Long totalMeasurementsRecorded;
    private Long totalProgressPhotos;
    private Long usersWithActiveStreaks;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PopularItem {
        private Long id;
        private String name;
        private Long usageCount;
    }
}
