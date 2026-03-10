package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Single meal in AI-generated nutrition plan response.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiMealResult {
    private String mealName;
    private String mealType;         // BREAKFAST | LUNCH | DINNER | SNACK
    private String description;
    private Integer calories;
    private Float proteinG;
    private Float carbsG;
    private Float fatsG;
    private String recipeInstructions;
}
