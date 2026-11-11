package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.response.CompensationActionResponse;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import com.dev.backend.model.entity.CompensationAction;
import com.dev.backend.model.entity.MissedWorkout;
import com.dev.backend.model.enums.MissedWorkoutReason;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface MissedWorkoutMapper extends BaseMapper<MissedWorkout, RescheduleMissedWorkoutRequest, MissedWorkoutResponse> {

    @Override
    @Mapping(target = "sessionId", source = "workoutSession.sessionId")
    @Mapping(target = "sessionName", source = "workoutSession.sessionName")
    @Mapping(target = "planName", source = "workoutPlan.planName")
    @Mapping(target = "reason", expression = "java(parseReason(entity.getReason()))")
    @Mapping(target = "customReasonText", expression = "java(parseCustomReasonText(entity.getReason()))")
    @Mapping(target = "compensationActions", expression = "java(entity.getCompensationActions() != null && !entity.getCompensationActions().isEmpty() ? toCompensationResponseList(entity.getCompensationActions()) : null)")
    MissedWorkoutResponse toResponse(MissedWorkout entity);

    @Override
    MissedWorkout toEntity(RescheduleMissedWorkoutRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget MissedWorkout entity, RescheduleMissedWorkoutRequest request);

    CompensationActionResponse toCompensationResponse(CompensationAction entity);

    List<CompensationActionResponse> toCompensationResponseList(List<CompensationAction> entities);

    default MissedWorkoutReason parseReason(String reason) {
        if (reason == null) {
            return null;
        }
        try {
            if (reason.contains(":")) {
                String[] parts = reason.split(":", 2);
                return MissedWorkoutReason.valueOf(parts[0]);
            }
            return MissedWorkoutReason.valueOf(reason);
        } catch (Exception e) {
            return MissedWorkoutReason.OTHER;
        }
    }

    default String parseCustomReasonText(String reason) {
        if (reason == null) {
            return null;
        }
        try {
            if (reason.contains(":")) {
                String[] parts = reason.split(":", 2);
                MissedWorkoutReason.valueOf(parts[0]);
                return parts[1];
            }
            MissedWorkoutReason.valueOf(reason);
            return null;
        } catch (Exception e) {
            return reason;
        }
    }
}
