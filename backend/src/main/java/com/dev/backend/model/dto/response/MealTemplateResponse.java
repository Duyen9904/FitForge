package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MealType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for meal templates (UC-7.6)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealTemplateResponse {

    private Long mealTemplateId;
    private String mealName;
    private MealType mealType;
    private String description;
    private Integer calories;
    private Float proteinG;
    private Float carbsG;
    private Float fatsG;
    private String recipeInstructions;
}
