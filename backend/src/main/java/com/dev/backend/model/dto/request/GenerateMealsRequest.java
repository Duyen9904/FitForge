package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MealType;
import com.dev.backend.model.enums.PlanMealSource;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for generating meals (RCM or AI) for a date or date range.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenerateMealsRequest {

    @NotNull(message = "Source is required (RCM or AI)")
    private PlanMealSource source;

    /** Single date — generate meals for this day. */
    private LocalDate date;

    /** Range start — used with endDate for multi-day generation. */
    private LocalDate startDate;

    /** Range end — used with startDate for multi-day generation. */
    private LocalDate endDate;

    /** Optional — if set, generate only this meal type. If null, generate all types. */
    private MealType mealType;
}
