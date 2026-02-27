package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for recording body measurements (UC-8.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecordMeasurementRequest {

    @NotNull(message = "Measurement date is required")
    @PastOrPresent(message = "Measurement date cannot be in the future")
    private LocalDate measurementDate;

    @Positive(message = "Weight must be positive")
    private Float weightKg;

    @Positive(message = "Body fat percentage must be positive")
    private Float bodyFatPercentage;

    @Positive(message = "Chest measurement must be positive")
    private Float chestCm;

    @Positive(message = "Waist measurement must be positive")
    private Float waistCm;

    @Positive(message = "Hips measurement must be positive")
    private Float hipsCm;

    @Positive(message = "Biceps measurement must be positive")
    private Float bicepsCm;

    @Positive(message = "Thighs measurement must be positive")
    private Float thighsCm;

    // InBody-specific fields (optional, for manual InBody data entry)
    @Positive(message = "Skeletal muscle mass must be positive")
    private Float skeletalMuscleMass;

    @Positive(message = "Body fat mass must be positive")
    private Float bodyFatMass;

    @Positive(message = "Body water must be positive")
    private Float bodyWaterLiters;

    @Positive(message = "Basal metabolic rate must be positive")
    private Integer basalMetabolicRate;

    private Integer visceralFatLevel;

    @Positive(message = "Waist-hip ratio must be positive")
    private Float waistHipRatio;

    private Integer inBodyScore;

    private String notes;
}
