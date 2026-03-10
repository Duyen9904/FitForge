package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MealType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Request DTO for scheduling a meal template onto a specific date in a plan.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleMealRequest {

    /** Optional — if null, uses the user's active plan */
    private Long planId;

    @NotNull(message = "Template ID is required")
    private Long templateId;

    @NotNull(message = "Scheduled date is required")
    private LocalDate scheduledDate;

    @NotNull(message = "Meal type is required")
    private MealType mealType;

    private Instant mealTime;

    private String notes;
}
