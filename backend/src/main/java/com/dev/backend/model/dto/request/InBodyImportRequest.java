package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for manually importing InBody data (fallback when OCR fails).
 * Fields match InBody report structure.
 */
@Data
@Builder 
@NoArgsConstructor
@AllArgsConstructor
public class InBodyImportRequest {

    @PastOrPresent(message = "Test date cannot be in the future")
    private LocalDate testDate;

    @Positive(message = "Weight must be positive")
    private Float weightKg;

    @Positive(message = "Skeletal muscle mass must be positive")
    private Float skeletalMuscleMass;

    @Positive(message = "Body fat mass must be positive")
    private Float bodyFatMass;

    @Positive(message = "Body fat percentage must be positive")
    private Float bodyFatPercentage;

    @Positive(message = "Body water must be positive")
    private Float bodyWaterLiters;

    @Positive(message = "Basal metabolic rate must be positive")
    private Integer basalMetabolicRate;

    /** Visceral fat level (1-20 scale) */
    private Integer visceralFatLevel;

    @Positive(message = "Waist-hip ratio must be positive")
    private Float waistHipRatio;

    /** InBody score (0-100) */
    private Integer inBodyScore;

    private String notes;
}
