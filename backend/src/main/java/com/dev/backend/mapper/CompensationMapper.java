package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.CompensationAction;
import com.dev.backend.model.entity.MakeupWorkout;
import org.springframework.stereotype.Component;

/**
 * Mapper for Compensation entities and DTOs
 */
@Component
public class CompensationMapper {

    public CompensationActionResponse toCompensationResponse(CompensationAction entity) {
        String triggerType = entity.getCheatMealLog() != null ? "CHEAT_MEAL" : "MISSED_WORKOUT";
        
        return CompensationActionResponse.builder()
                .compensationId(entity.getCompensationId())
                .triggerType(triggerType)
                .status(entity.getStatus().name())
                .statusDisplayName(entity.getStatus().getDisplayName())
                .actionType(entity.getActionType())
                .actionDescription(entity.getActionDescription())
                .scheduledDate(entity.getScheduledDate())
                .validUntilDate(entity.getValidUntilDate())
                .isCompleted(entity.getIsCompleted())
                .calorieAdjustment(entity.getCalorieAdjustment())
                .details(entity.getDetails())
                .createdAt(entity.getCreatedAt())
                .completedAt(entity.getCompletedAt())
                .build();
    }

    public CompensationOptionResponse toOptionResponse(CompensationAction entity, boolean isRecommended, String reason) {
        return CompensationOptionResponse.builder()
                .compensationId(entity.getCompensationId())
                .actionType(entity.getActionType())
                .actionTypeDisplayName(formatActionType(entity.getActionType()))
                .actionDescription(entity.getActionDescription())
                .calorieAdjustment(entity.getCalorieAdjustment())
                .suggestedDate(entity.getScheduledDate())
                .durationDays(calculateDurationDays(entity))
                .expectedImpact(generateExpectedImpact(entity))
                .isRecommended(isRecommended)
                .recommendationReason(reason)
                .build();
    }

    public MakeupWorkoutResponse toMakeupWorkoutResponse(MakeupWorkout entity) {
        return MakeupWorkoutResponse.builder()
                .makeupId(entity.getMakeupId())
                .originalSessionId(entity.getOriginalSession().getSessionId())
                .originalSessionName(entity.getOriginalSession().getSessionName())
                .replacementSessionId(entity.getReplacementSession() != null ? 
                        entity.getReplacementSession().getSessionId() : null)
                .scheduledMakeupDate(entity.getScheduledMakeupDate())
                .adjustmentType(entity.getAdjustmentType())
                .adjustmentNotes(entity.getAdjustmentNotes())
                .isCompleted(entity.getIsCompleted())
                .build();
    }

    private String formatActionType(String actionType) {
        if (actionType == null) return "";
        return actionType.replace("_", " ");
    }

    private Integer calculateDurationDays(CompensationAction entity) {
        if (entity.getScheduledDate() == null || entity.getValidUntilDate() == null) {
            return 1;
        }
        return (int) (entity.getValidUntilDate().toEpochDay() - entity.getScheduledDate().toEpochDay()) + 1;
    }

    private String generateExpectedImpact(CompensationAction entity) {
        if (entity.getCalorieAdjustment() != null && entity.getCalorieAdjustment() < 0) {
            return "Reduce " + Math.abs(entity.getCalorieAdjustment()) + " calories to offset excess intake";
        }
        return "Complete the assigned activity to maintain progress";
    }
}
