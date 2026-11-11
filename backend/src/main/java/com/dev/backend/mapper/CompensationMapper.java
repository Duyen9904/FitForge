package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.SelectCompensationRequest;
import com.dev.backend.model.dto.response.CompensationActionResponse;
import com.dev.backend.model.dto.response.CompensationOptionResponse;
import com.dev.backend.model.dto.response.MakeupWorkoutResponse;
import com.dev.backend.model.entity.CompensationAction;
import com.dev.backend.model.entity.MakeupWorkout;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

/**
 * Mapper for Compensation entities and DTOs
 */
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface CompensationMapper extends BaseMapper<CompensationAction, SelectCompensationRequest, CompensationActionResponse> {

    @Override
    @Mapping(target = "triggerType", expression = "java(entity.getCheatMealLog() != null ? \"CHEAT_MEAL\" : \"MISSED_WORKOUT\")")
    @Mapping(target = "status", expression = "java(entity.getStatus() != null ? entity.getStatus().name() : null)")
    @Mapping(target = "statusDisplayName", expression = "java(entity.getStatus() != null ? entity.getStatus().getDisplayName() : null)")
    CompensationActionResponse toResponse(CompensationAction entity);

    @Override
    CompensationAction toEntity(SelectCompensationRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget CompensationAction entity, SelectCompensationRequest request);

    default CompensationActionResponse toCompensationResponse(CompensationAction entity) {
        return toResponse(entity);
    }

    @Mapping(target = "compensationId", source = "entity.compensationId")
    @Mapping(target = "actionType", source = "entity.actionType")
    @Mapping(target = "actionTypeDisplayName", expression = "java(formatActionType(entity.getActionType()))")
    @Mapping(target = "actionDescription", source = "entity.actionDescription")
    @Mapping(target = "calorieAdjustment", source = "entity.calorieAdjustment")
    @Mapping(target = "suggestedDate", source = "entity.scheduledDate")
    @Mapping(target = "durationDays", expression = "java(calculateDurationDays(entity))")
    @Mapping(target = "expectedImpact", expression = "java(generateExpectedImpact(entity))")
    @Mapping(target = "isRecommended", source = "isRecommended")
    @Mapping(target = "recommendationReason", source = "reason")
    CompensationOptionResponse toOptionResponse(CompensationAction entity, boolean isRecommended, String reason);

    @Mapping(target = "originalSessionId", source = "originalSession.sessionId")
    @Mapping(target = "originalSessionName", source = "originalSession.sessionName")
    @Mapping(target = "replacementSessionId", source = "replacementSession.sessionId")
    MakeupWorkoutResponse toMakeupWorkoutResponse(MakeupWorkout entity);

    default String formatActionType(String actionType) {
        if (actionType == null) return "";
        return actionType.replace("_", " ");
    }

    default Integer calculateDurationDays(CompensationAction entity) {
        if (entity == null || entity.getScheduledDate() == null || entity.getValidUntilDate() == null) {
            return 1;
        }
        return (int) (entity.getValidUntilDate().toEpochDay() - entity.getScheduledDate().toEpochDay()) + 1;
    }

    default String generateExpectedImpact(CompensationAction entity) {
        if (entity != null && entity.getCalorieAdjustment() != null && entity.getCalorieAdjustment() < 0) {
            return "Reduce " + Math.abs(entity.getCalorieAdjustment()) + " calories to offset excess intake";
        }
        return "Complete the assigned activity to maintain progress";
    }
}
