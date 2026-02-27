package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for a single body measurement record (UC-8.1, UC-8.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeasurementResponse {

    private Long measurementId;
    private LocalDate measurementDate;
    private Float weightKg;
    private Float bodyFatPercentage;
    private Float chestCm;
    private Float waistCm;
    private Float hipsCm;
    private Float bicepsCm;
    private Float thighsCm;
    private String notes;

    // InBody-specific fields
    private Float skeletalMuscleMass;
    private Float bodyFatMass;
    private Float bodyWaterLiters;
    private Integer basalMetabolicRate;
    private Integer visceralFatLevel;
    private Float waistHipRatio;
    private Integer inBodyScore;
    private String source;

    // Change indicators compared to previous measurement
    private Float weightChange;
    private Float bodyFatChange;
}
