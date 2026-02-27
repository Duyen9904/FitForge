package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.model.enums.RescheduleReason;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Response DTO for compensation action (UC-11)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CompensationActionResponse {
    
    private Long compensationId;
    private String triggerType; // "CHEAT_MEAL" or "MISSED_WORKOUT"
    private String status;
    private String statusDisplayName;
    private String actionType;
    private String actionDescription;
    private LocalDate scheduledDate;
    private LocalDate validUntilDate;
    private Boolean isCompleted;
    private Integer calorieAdjustment;
    private String details;
    private Instant createdAt;
    private Instant completedAt;
    private RescheduleReason rescheduleReason;
    
    // Fields used by existing NutritionMapper
    private CompensationType compensationType;
    private Integer daysRemaining;
    private String progressStatus;
}
