package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * AI response DTO for a complete nutrition plan with meals.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiNutritionPlanResult {
    private String planName;
    private String description;
    private String recommendationReason;
    private Integer dailyCalorieTarget;
    private Float proteinPercentage;
    private Float carbsPercentage;
    private Float fatsPercentage;
    private Integer cheatMealsPerWeek;
    private List<AiMealResult> meals;
}
