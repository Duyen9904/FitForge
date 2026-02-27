package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for daily nutrition summary (UC-7.5)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyNutritionSummaryResponse {

    private LocalDate date;
    
    // Consumed totals
    private Integer totalCalories;
    private Float totalProteinG;
    private Float totalCarbsG;
    private Float totalFatsG;
    
    // Targets
    private Integer targetCalories;
    private Float targetProteinG;
    private Float targetCarbsG;
    private Float targetFatsG;
    
    // Remaining
    private Integer remainingCalories;
    private Float remainingProteinG;
    private Float remainingCarbsG;
    private Float remainingFatsG;
    
    // Progress percentages
    private Float calorieProgress;
    private Float proteinProgress;
    private Float carbsProgress;
    private Float fatsProgress;
    
    private Integer cheatMealCount;
}
