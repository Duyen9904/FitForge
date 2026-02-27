package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for weekly workout progress visualization
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyWorkoutProgressResponse {
    
    private String weekLabel;          // e.g., "Feb 9-15"
    private LocalDate startDate;
    private LocalDate endDate;
    private List<DailyWorkoutData> dailyData;
    private WeeklySummary summary;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyWorkoutData {
        private LocalDate date;
        private String dayOfWeek;          // "Sun", "Mon", etc.
        private boolean isToday;
        private Integer workoutsCompleted;
        private Integer minutesExercised;
        private Integer caloriesBurned;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklySummary {
        private Integer totalWorkoutsCompleted;
        private Integer totalMinutesExercised;
        private Integer totalCaloriesBurned;
        private Float averageWorkoutDuration;
    }
}
