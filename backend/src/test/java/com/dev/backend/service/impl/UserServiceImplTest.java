package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.UserMapper;
import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.User.Role;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private GoalRepository goalRepository;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    private User mockUser;
    private Goal mockGoal;
    private UserProfileResponse mockProfileResponse;

    @BeforeEach
    void setUp() {
        mockGoal = new Goal();
        mockGoal.setGoalId(1L);
        mockGoal.setGoalName("Fat Loss");

        mockUser = new User();
        mockUser.setUserId(1L);
        mockUser.setUsername("testuser");
        mockUser.setEmail("test@example.com");
        mockUser.setRole(Role.USER);

        GoalResponse goalResponse = GoalResponse.builder()
                .goalId(1L)
                .goalName("Fat Loss")
                .build();

        mockProfileResponse = UserProfileResponse.builder()
                .userId(1L)
                .username("testuser")
                .email("test@example.com")
                .primaryGoal(goalResponse)
                .build();
    }

    @Nested
    @DisplayName("getCurrentUserProfile")
    class GetCurrentUserProfileTests {

        @Test
        @DisplayName("Should return user profile successfully")
        void getCurrentUserProfile_Success() {
            // Given
            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(userMapper.toUserProfileResponse(mockUser)).thenReturn(mockProfileResponse);

            // When
            UserProfileResponse result = userService.getCurrentUserProfile(1L);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getUserId()).isEqualTo(1L);
            assertThat(result.getUsername()).isEqualTo("testuser");
            verify(userRepository, times(1)).findById(1L);
            verify(userMapper, times(1)).toUserProfileResponse(mockUser);
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when user not found")
        void getCurrentUserProfile_NotFound() {
            // Given
            when(userRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> userService.getCurrentUserProfile(999L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("User not found");
        }
    }

    @Nested
    @DisplayName("setPrimaryGoal")
    class SetPrimaryGoalTests {

        @Test
        @DisplayName("Should set primary goal successfully")
        void setPrimaryGoal_Success() {
            // Given
            SetPrimaryGoalRequest request = SetPrimaryGoalRequest.builder()
                    .goalId(1L)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
                User saved = invocation.getArgument(0);
                saved.setPrimaryGoal(mockGoal);
                return saved;
            });
            when(userMapper.toUserProfileResponse(any(User.class))).thenReturn(mockProfileResponse);

            // When
            UserProfileResponse result = userService.setPrimaryGoal(1L, request);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getPrimaryGoal()).isNotNull();
            assertThat(result.getPrimaryGoal().getGoalId()).isEqualTo(1L);
            verify(userRepository, times(1)).save(any(User.class));
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when user not found")
        void setPrimaryGoal_UserNotFound() {
            // Given
            SetPrimaryGoalRequest request = SetPrimaryGoalRequest.builder()
                    .goalId(1L)
                    .build();
            when(userRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> userService.setPrimaryGoal(999L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("User not found");
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when goal not found")
        void setPrimaryGoal_GoalNotFound() {
            // Given
            SetPrimaryGoalRequest request = SetPrimaryGoalRequest.builder()
                    .goalId(999L)
                    .build();
            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(goalRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> userService.setPrimaryGoal(1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Goal not found");
        }
    }
}
