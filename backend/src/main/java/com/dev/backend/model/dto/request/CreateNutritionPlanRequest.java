package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating a nutrition plan (UC-7.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateNutritionPlanRequest {

    @NotBlank(message = "Plan name is required")
    @Size(max = 100, message = "Plan name must not exceed 100 characters")
    private String planName;

    private Long goalId;

    @NotNull(message = "Daily calorie target is required")
    @Positive(message = "Daily calorie target must be positive")
    @Max(value = 10000, message = "Daily calorie target seems unrealistic")
    private Integer dailyCalorieTarget;

    @NotNull(message = "Protein percentage is required")
    @DecimalMin(value = "0.0", message = "Protein percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Protein percentage must not exceed 100")
    private Float proteinPercentage;

    @NotNull(message = "Carbs percentage is required")
    @DecimalMin(value = "0.0", message = "Carbs percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Carbs percentage must not exceed 100")
    private Float carbsPercentage;

    @NotNull(message = "Fats percentage is required")
    @DecimalMin(value = "0.0", message = "Fats percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Fats percentage must not exceed 100")
    private Float fatsPercentage;

    @PositiveOrZero(message = "Cheat meals per week must be non-negative")
    @Max(value = 7, message = "Cheat meals per week cannot exceed 7")
    private Integer cheatMealsPerWeek;

    private Boolean autoAdjustEnabled;

    @AssertTrue(message = "Macro percentages must sum to 100")
    private boolean isMacroPercentagesValid() {
        if (proteinPercentage == null || carbsPercentage == null || fatsPercentage == null) {
            return true; // Let @NotNull handle this
        }
        float total = proteinPercentage + carbsPercentage + fatsPercentage;
        return Math.abs(total - 100.0f) < 0.01f;
    }
}
