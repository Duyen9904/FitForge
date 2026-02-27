package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MealType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Request DTO for logging a meal (UC-7.2, UC-7.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LogMealRequest {

    @NotNull(message = "Meal type is required")
    private MealType mealType;

    @NotBlank(message = "Food name is required")
    @Size(max = 200, message = "Food name must not exceed 200 characters")
    private String foodName;

    @NotNull(message = "Calories are required")
    @PositiveOrZero(message = "Calories must be non-negative")
    private Integer calories;

    @PositiveOrZero(message = "Protein must be non-negative")
    private Float proteinG;

    @PositiveOrZero(message = "Carbs must be non-negative")
    private Float carbsG;

    @PositiveOrZero(message = "Fats must be non-negative")
    private Float fatsG;

    private Instant mealTime;

    private LocalDate logDate;

    private Boolean isCheatMeal;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;
}
