package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.UserPreferenceResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserPreference;
import org.mapstruct.BeanMapping;
import org.mapstruct.InjectionStrategy;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        uses = {GoalMapper.class},
        injectionStrategy = InjectionStrategy.CONSTRUCTOR,
        unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface UserMapper extends BaseMapper<User, SetPrimaryGoalRequest, UserProfileResponse> {

    @Override
    UserProfileResponse toResponse(User user);

    @Override
    User toEntity(SetPrimaryGoalRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget User entity, SetPrimaryGoalRequest request);

    default UserProfileResponse toUserProfileResponse(User user) {
        return toResponse(user);
    }

    UserPreferenceResponse toUserPreferenceResponse(UserPreference pref);
}
