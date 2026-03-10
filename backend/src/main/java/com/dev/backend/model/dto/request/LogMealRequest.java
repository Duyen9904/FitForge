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
 * Request DTO for logging a meal (UC-7.2, UC-7.3, UC-7.7).
 *
 * Two modes:
 * - Template-based: provide {@code templateId} (and optional {@code quantityMultiplier}).
 * - Manual: provide {@code mealType}, {@code foodName}, {@code calories}, etc.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LogMealRequest {

    // ── Template-based fields (optional) ─────────────────────────────────

    /** If set, meal data is copied from this template. Manual fields are ignored. */
    private Long templateId;

    /** Multiplier applied to template macros/calories (defaults to 1.0). */
    @Positive(message = "Quantity multiplier must be positive")
    private Float quantityMultiplier;

    // ── Manual-entry fields (required when templateId is absent) ─────────

    private MealType mealType;

    @Size(max = 200, message = "Food name must not exceed 200 characters")
    private String foodName;

    @PositiveOrZero(message = "Calories must be non-negative")
    private Integer calories;

    @PositiveOrZero(message = "Protein must be non-negative")
    private Float proteinG;

    @PositiveOrZero(message = "Carbs must be non-negative")
    private Float carbsG;

    @PositiveOrZero(message = "Fats must be non-negative")
    private Float fatsG;

    // ── Common fields ────────────────────────────────────────────────────

    private Instant mealTime;

    private LocalDate logDate;

    private Boolean isCheatMeal;

    /** If true, delete existing meal(s) of the same type on this date before logging. */
    private Boolean replaceExisting;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;
}
