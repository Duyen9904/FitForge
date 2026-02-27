package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating a nutrition plan (UC-7.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateNutritionPlanRequest {

    @Size(max = 100, message = "Plan name must not exceed 100 characters")
    private String planName;

    private Long goalId;

    @Positive(message = "Daily calorie target must be positive")
    @Max(value = 10000, message = "Daily calorie target seems unrealistic")
    private Integer dailyCalorieTarget;

    @DecimalMin(value = "0.0", message = "Protein percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Protein percentage must not exceed 100")
    private Float proteinPercentage;

    @DecimalMin(value = "0.0", message = "Carbs percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Carbs percentage must not exceed 100")
    private Float carbsPercentage;

    @DecimalMin(value = "0.0", message = "Fats percentage must be at least 0")
    @DecimalMax(value = "100.0", message = "Fats percentage must not exceed 100")
    private Float fatsPercentage;

    @PositiveOrZero(message = "Cheat meals per week must be non-negative")
    @Max(value = 7, message = "Cheat meals per week cannot exceed 7")
    private Integer cheatMealsPerWeek;

    private Boolean autoAdjustEnabled;
}
