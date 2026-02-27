package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.AccountSummaryDto;
import com.dev.backend.model.entity.User;
import org.springframework.stereotype.Component;

/**
 * Mapper for converting between User entity and Account DTOs
 */
@Component
public class AccountMapper implements BaseMapper<User, RegisterRequestDto, AccountSummaryDto> {

    /**
     * Convert User entity to AccountSummaryDto response
     */
    @Override
    public AccountSummaryDto toResponse(User entity) {
        if (entity == null) {
            return null;
        }
        return AccountSummaryDto.builder()
                .userId(entity.getUserId())
                .username(entity.getUsername())
                .email(entity.getEmail())
                .dateOfBirth(entity.getDateOfBirth())
                .gender(entity.getGender())
                .heightCm(entity.getHeightCm())
                .currentWeightKg(entity.getCurrentWeightKg())
                .targetWeightKg(entity.getTargetWeightKg())
                .fitnessLevel(entity.getFitnessLevel())
                .profileImageUrl(entity.getProfileImageUrl())
                .role(entity.getRole() != null ? entity.getRole().name() : null)
                .dateJoined(entity.getDateJoined())
                .build();
    }

    /**
     * Convert RegisterRequestDto to User entity
     * Note: passwordHash should be set separately after encoding
     */
    @Override
    public User toEntity(RegisterRequestDto request) {
        if (request == null) {
            return null;
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        // Password hash should be set separately after encoding
        // Other profile fields (dateOfBirth, gender, height, weight, fitnessLevel) 
        // will be collected during onboarding
        user.setRole(User.Role.USER); // Default role for new registrations
        return user;
    }

    /**
     * Update existing User entity from RegisterRequestDto
     * Useful for profile updates
     */
    @Override
    public void updateEntityFromRequest(User entity, RegisterRequestDto request) {
        if (entity == null || request == null) {
            return;
        }
        if (request.getUsername() != null) {
            entity.setUsername(request.getUsername());
        }
        if (request.getEmail() != null) {
            entity.setEmail(request.getEmail());
        }
        // Password update should be handled separately with encoding
        // Other profile fields are updated via onboarding/profile endpoints
    }
}
