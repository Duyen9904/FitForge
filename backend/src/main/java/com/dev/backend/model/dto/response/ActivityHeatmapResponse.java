package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for the GitHub-style workout activity heatmap.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ActivityHeatmapResponse {

    private LocalDate startDate;
    private LocalDate endDate;
    private int totalActiveDays;
    private int totalWorkouts;
    private List<DailyActivity> dailyActivities;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyActivity {
        private LocalDate date;
        private int workoutsCompleted;
        private int totalMinutes;
        private int caloriesBurned;
    }
}
