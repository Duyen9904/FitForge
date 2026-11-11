package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface GoalMapper extends BaseMapper<Goal, CreateGoalRequest, GoalResponse> {

    @Override
    GoalResponse toResponse(Goal entity);

    @Override
    Goal toEntity(CreateGoalRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget Goal entity, CreateGoalRequest request);

    @Named("toGoalResponse")
    default GoalResponse toGoalResponse(Goal goal) {
        return toResponse(goal);
    }
}
