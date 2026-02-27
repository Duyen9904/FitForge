package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Request DTO for logging a meal from a saved template (UC-7.7)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LogMealFromTemplateRequest {

    @NotNull(message = "Template ID is required")
    private Long templateId;

    @Positive(message = "Quantity multiplier must be positive")
    private Float quantityMultiplier;

    private Instant mealTime;

    private LocalDate logDate;

    private Boolean isCheatMeal;
}
