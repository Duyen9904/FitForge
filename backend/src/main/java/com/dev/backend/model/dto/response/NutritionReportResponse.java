package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class NutritionReportResponse {

    private LocalDate startDate;
    private LocalDate endDate;

    // Daily Averages
    private Double averageDailyCalories;
    private Double averageDailyProtein;
    private Double averageDailyCarbs;
    private Double averageDailyFats;

    // Target Adherence
    private Double calorieAdherencePercentage;
    private Double proteinAdherencePercentage;
    private Double carbsAdherencePercentage;
    private Double fatsAdherencePercentage;

    // Macro Distribution
    private Double proteinPercentage;
    private Double carbsPercentage;
    private Double fatsPercentage;

    // Trends
    private Double averageCalorieSurplus;  // Positive = surplus, Negative = deficit
    private Integer totalCheatMealDays;
    private Double cheatMealFrequencyPerWeek;

    // Daily Breakdown
    private List<DailyNutritionItem> dailyBreakdown;

    // Recommendations
    private List<String> recommendations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyNutritionItem {
        private LocalDate date;
        private Integer calories;
        private Double protein;
        private Double carbs;
        private Double fats;
        private Boolean meetsTarget;
    }
}
