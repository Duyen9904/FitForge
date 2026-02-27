package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for setting measurement goals (UC-8.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SetMeasurementGoalRequest {

    @Positive(message = "Target weight must be positive")
    private Float targetWeightKg;

    @Positive(message = "Target body fat must be positive")
    private Float targetBodyFatPercentage;

    @Positive(message = "Target chest measurement must be positive")
    private Float targetChestCm;

    @Positive(message = "Target waist measurement must be positive")
    private Float targetWaistCm;

    @Positive(message = "Target hips measurement must be positive")
    private Float targetHipsCm;

    @Positive(message = "Target biceps measurement must be positive")
    private Float targetBicepsCm;

    @Positive(message = "Target thighs measurement must be positive")
    private Float targetThighsCm;

    @Future(message = "Target date must be in the future")
    private LocalDate targetDate;

    private String notes;
}
