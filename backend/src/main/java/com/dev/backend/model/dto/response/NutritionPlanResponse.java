package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for nutrition plan (UC-7.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionPlanResponse {

    private Long nutritionPlanId;
    private String planName;
    private Long goalId;
    private String goalName;
    private Integer dailyCalorieTarget;

    // Recommendation metadata
    private String algorithmVersion;
    private Integer version;
    private String recommendationReason;
    
    // Percentages
    private Float proteinPercentage;
    private Float carbsPercentage;
    private Float fatsPercentage;
    
    // Calculated grams based on calorie target
    private Float proteinGrams;
    private Float carbsGrams;
    private Float fatsGrams;
    
    private Integer cheatMealsPerWeek;
    private Boolean autoAdjustEnabled;
    private Boolean isActive;
    
    // Meal templates (Day 1 initially, more on-demand)
    private List<MealTemplateResponse> mealTemplates;
}
