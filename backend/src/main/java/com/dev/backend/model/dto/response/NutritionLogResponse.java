package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MealType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Response DTO for a nutrition log entry (UC-7.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionLogResponse {

    private Long nutritionId;
    private LocalDate logDate;
    private MealType mealType;
    private String foodName;
    private Integer calories;
    private Float proteinG;
    private Float carbsG;
    private Float fatsG;
    private Instant mealTime;
    private Boolean isCheatMeal;
    private String notes;
}
