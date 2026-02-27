package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.CompensationActionResponse;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import com.dev.backend.model.entity.CompensationAction;
import com.dev.backend.model.entity.MissedWorkout;
import com.dev.backend.model.enums.MissedWorkoutReason;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class MissedWorkoutMapper {

    public MissedWorkoutResponse toResponse(MissedWorkout entity) {
        MissedWorkoutResponse.MissedWorkoutResponseBuilder builder = MissedWorkoutResponse.builder()
                .missedWorkoutId(entity.getMissedWorkoutId())
                .scheduledDate(entity.getScheduledDate())
                .missedDate(entity.getMissedDate())
                .isReplanned(entity.getIsReplanned())
                .replanStrategy(entity.getReplanStrategy());

        // Parse reason
        if (entity.getReason() != null) {
            try {
                // Check if reason contains custom text (format: "REASON:custom text")
                if (entity.getReason().contains(":")) {
                    String[] parts = entity.getReason().split(":", 2);
                    builder.reason(MissedWorkoutReason.valueOf(parts[0]));
                    builder.customReasonText(parts[1]);
                } else {
                    builder.reason(MissedWorkoutReason.valueOf(entity.getReason()));
                }
            } catch (Exception e) {
                // If enum parsing fails, treat entire string as custom reason
                builder.reason(MissedWorkoutReason.OTHER);
                builder.customReasonText(entity.getReason());
            }
        }

        // Session info
        if (entity.getWorkoutSession() != null) {
            builder.sessionId(entity.getWorkoutSession().getSessionId());
            builder.sessionName(entity.getWorkoutSession().getSessionName());
        }

        // Plan info
        if (entity.getWorkoutPlan() != null) {
            builder.planName(entity.getWorkoutPlan().getPlanName());
        }

        // Compensation actions
        if (entity.getCompensationActions() != null && !entity.getCompensationActions().isEmpty()) {
            List<CompensationActionResponse> actions = entity.getCompensationActions().stream()
                    .map(this::toCompensationResponse)
                    .collect(Collectors.toList());
            builder.compensationActions(actions);
        }

        return builder.build();
    }

    private CompensationActionResponse toCompensationResponse(CompensationAction entity) {
        return CompensationActionResponse.builder()
                .compensationId(entity.getCompensationId())
                .actionType(entity.getActionType())
                .actionDescription(entity.getActionDescription())
                .scheduledDate(entity.getScheduledDate())
                .isCompleted(entity.getIsCompleted())
                .details(entity.getDetails())
                .rescheduleReason(entity.getRescheduleReason())
                .build();
    }
}
