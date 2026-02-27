package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.User.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class UserMapperTest {

    private UserMapper userMapper;
    private GoalMapper goalMapper;

    @BeforeEach
    void setUp() {
        goalMapper = new GoalMapper();
        userMapper = new UserMapper(goalMapper);
    }

    @Test
    @DisplayName("Should map User entity to UserProfileResponse with primary goal")
    void toUserProfileResponse_WithPrimaryGoal() {
        // Given
        Goal goal = new Goal();
        goal.setGoalId(1L);
        goal.setGoalName("Fat Loss");
        goal.setDescription("Reduce body fat");

        User user = new User();
        user.setUserId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setDateOfBirth(LocalDate.of(1990, 5, 15));
        user.setGender("MALE");
        user.setHeightCm(180.0f);
        user.setCurrentWeightKg(80.0f);
        user.setTargetWeightKg(75.0f);
        user.setFitnessLevel("INTERMEDIATE");
        user.setRole(Role.USER);
        user.setPrimaryGoal(goal);

        // When
        UserProfileResponse response = userMapper.toUserProfileResponse(user);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUsername()).isEqualTo("testuser");
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getGender()).isEqualTo("MALE");
        assertThat(response.getHeightCm()).isEqualTo(180.0f);
        assertThat(response.getCurrentWeightKg()).isEqualTo(80.0f);
        assertThat(response.getTargetWeightKg()).isEqualTo(75.0f);
        assertThat(response.getFitnessLevel()).isEqualTo("INTERMEDIATE");

        // Verify primary goal mapping
        assertThat(response.getPrimaryGoal()).isNotNull();
        assertThat(response.getPrimaryGoal().getGoalId()).isEqualTo(1L);
        assertThat(response.getPrimaryGoal().getGoalName()).isEqualTo("Fat Loss");
    }

    @Test
    @DisplayName("Should map User entity without primary goal")
    void toUserProfileResponse_WithoutPrimaryGoal() {
        // Given
        User user = new User();
        user.setUserId(2L);
        user.setUsername("newuser");
        user.setEmail("new@example.com");
        user.setRole(Role.USER);
        user.setPrimaryGoal(null);

        // When
        UserProfileResponse response = userMapper.toUserProfileResponse(user);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(2L);
        assertThat(response.getUsername()).isEqualTo("newuser");
        assertThat(response.getPrimaryGoal()).isNull();
    }

    @Test
    @DisplayName("Should handle all null optional fields")
    void toUserProfileResponse_AllNullOptionalFields() {
        // Given
        User user = new User();
        user.setUserId(3L);
        user.setUsername("minimaluser");
        user.setEmail("minimal@example.com");
        user.setRole(Role.USER);

        // When
        UserProfileResponse response = userMapper.toUserProfileResponse(user);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(3L);
        assertThat(response.getDateOfBirth()).isNull();
        assertThat(response.getGender()).isNull();
        assertThat(response.getHeightCm()).isNull();
        assertThat(response.getCurrentWeightKg()).isNull();
        assertThat(response.getTargetWeightKg()).isNull();
        assertThat(response.getFitnessLevel()).isNull();
    }
}
