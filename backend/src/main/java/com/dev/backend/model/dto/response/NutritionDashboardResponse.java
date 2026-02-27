package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for nutrition dashboard (UC-7.5)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionDashboardResponse {

    private DailyNutritionSummaryResponse todaySummary;
    private List<NutritionLogResponse> recentMeals;
    private WeeklyCheatMealSummary weeklyCheatMeals;
    private List<CompensationActionResponse> activeCompensations;
    private NutritionTrendSummary trends;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklyCheatMealSummary {
        private Integer usedThisWeek;
        private Integer allowedPerWeek;
        private Integer remaining;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionTrendSummary {
        private List<DailyTrendPoint> last7Days;
        private Float averageDailyCalories;
        private Float averageDailyProtein;
        private String adherenceStatus; // "on_track", "over_target", "under_target"
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyTrendPoint {
        private LocalDate date;
        private Integer calories;
        private Float proteinG;
        private Float carbsG;
        private Float fatsG;
    }
}
