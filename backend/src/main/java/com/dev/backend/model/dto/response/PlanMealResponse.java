package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MealType;
import com.dev.backend.model.enums.PlanMealSource;
import com.dev.backend.model.enums.PlanMealStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Response DTO for a plan meal entry.
 * Response DTO for plan meal data.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlanMealResponse {

    private Long planMealId;
    private Long nutritionPlanId;
    private Long mealTemplateId;
    private LocalDate scheduledDate;
    private MealType mealType;
    private PlanMealStatus status;
    private PlanMealSource source;

    // Denormalized meal data
    private String foodName;
    private Integer calories;
    private Float proteinG;
    private Float carbsG;
    private Float fatsG;

    private Instant mealTime;
    private Instant completedAt;
    private Boolean isCheatMeal;
    private String notes;

    // Nested template details — null for manually created meals
    private MealTemplateResponse mealTemplate;
}
