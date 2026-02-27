package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for compensation option (UC-11.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CompensationOptionResponse {
    
    private Long compensationId;
    private String actionType; // ADD_CARDIO, REDUCE_CALORIES, RESCHEDULE_WORKOUT, etc.
    private String actionTypeDisplayName;
    private String actionDescription;
    private Integer calorieAdjustment;
    private LocalDate suggestedDate;
    private Integer durationDays; // How many days the compensation spans
    private String expectedImpact; // Description of expected result
    private Boolean isRecommended; // System recommendation
    private String recommendationReason;
}
