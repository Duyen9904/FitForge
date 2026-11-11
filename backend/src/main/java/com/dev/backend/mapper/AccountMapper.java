package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.AccountSummaryDto;
import com.dev.backend.model.entity.User;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

/**
 * Mapper for converting between User entity and Account DTOs
 */
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface AccountMapper extends BaseMapper<User, RegisterRequestDto, AccountSummaryDto> {

    /**
     * Convert User entity to AccountSummaryDto response
     */
    @Override
    @Mapping(target = "role", expression = "java(entity.getRole() != null ? entity.getRole().name() : null)")
    AccountSummaryDto toResponse(User entity);

    /**
     * Convert RegisterRequestDto to User entity
     * Note: passwordHash should be set separately after encoding
     */
    @Override
    @Mapping(target = "role", constant = "USER")
    User toEntity(RegisterRequestDto request);

    /**
     * Update existing User entity from RegisterRequestDto
     * Useful for profile updates
     */
    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget User entity, RegisterRequestDto request);
}
