package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MealType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating a meal template (UC-7.6)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateMealTemplateRequest {

    @NotBlank(message = "Meal name is required")
    @Size(max = 100, message = "Meal name must not exceed 100 characters")
    private String mealName;

    @NotNull(message = "Meal type is required")
    private MealType mealType;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @NotNull(message = "Calories are required")
    @PositiveOrZero(message = "Calories must be non-negative")
    private Integer calories;

    @PositiveOrZero(message = "Protein must be non-negative")
    private Float proteinG;

    @PositiveOrZero(message = "Carbs must be non-negative")
    private Float carbsG;

    @PositiveOrZero(message = "Fats must be non-negative")
    private Float fatsG;

    @Size(max = 2000, message = "Recipe instructions must not exceed 2000 characters")
    private String recipeInstructions;
}
