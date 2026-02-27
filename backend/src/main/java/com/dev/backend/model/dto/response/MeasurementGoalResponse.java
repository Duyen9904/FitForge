package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for measurement goals (UC-8.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeasurementGoalResponse {

    private Long goalId;
    private Float targetWeightKg;
    private Float targetBodyFatPercentage;
    private Float targetChestCm;
    private Float targetWaistCm;
    private Float targetHipsCm;
    private Float targetBicepsCm;
    private Float targetThighsCm;
    private LocalDate targetDate;
    private Boolean isActive;
    private String notes;

    // Calculated fields
    private Long daysRemaining;
    private RequiredWeeklyChanges requiredWeeklyChanges;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RequiredWeeklyChanges {
        private Float weeklyWeightChange;
        private Float weeklyBodyFatChange;
        private String recommendation;
    }
}
