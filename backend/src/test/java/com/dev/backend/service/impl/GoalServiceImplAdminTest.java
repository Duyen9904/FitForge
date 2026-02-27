package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.GoalMapper;
import com.dev.backend.model.dto.request.CreateGoalRequest;
import com.dev.backend.model.dto.request.UpdateGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.repository.WorkoutPlanRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests for GoalServiceImpl admin methods (UC-16.2)
 */
@ExtendWith(MockitoExtension.class)
class GoalServiceImplAdminTest {

    @Mock
    private GoalRepository goalRepository;

    @Mock
    private GoalMapper goalMapper;

    @Mock
    private WorkoutPlanRepository workoutPlanRepository;

    @Mock
    private UserRepository userRepository;

    private GoalServiceImpl goalService;

    private Goal mockGoal;
    private GoalResponse mockGoalResponse;

    @BeforeEach
    void setUp() {
        goalService = new GoalServiceImpl(goalRepository, goalMapper, workoutPlanRepository, userRepository);

        mockGoal = new Goal();
        mockGoal.setGoalId(1L);
        mockGoal.setGoalName("Fat Loss");
        mockGoal.setDescription("Reduce body fat");
        mockGoal.setRecommendedRepRange("12-15");
        mockGoal.setRecommendedRestTime("60 seconds");
        mockGoal.setRecommendedFrequency("4-5 days/week");
        mockGoal.setTargetCalorieAdjustment(-500);

        mockGoalResponse = GoalResponse.builder()
                .goalId(1L)
                .goalName("Fat Loss")
                .description("Reduce body fat")
                .recommendedRepRange("12-15")
                .recommendedRestTime("60 seconds")
                .recommendedFrequency("4-5 days/week")
                .targetCalorieAdjustment(-500)
                .build();
    }

    @Nested
    @DisplayName("createGoal (UC-16.2)")
    class CreateGoalTests {

        @Test
        @DisplayName("Should create a new goal successfully")
        void createGoal_Success() {
            // Given
            CreateGoalRequest request = CreateGoalRequest.builder()
                    .goalName("Strength Building")
                    .description("Increase strength and power")
                    .recommendedRepRange("3-5")
                    .recommendedRestTime("3-5 minutes")
                    .recommendedFrequency("3-4 days/week")
                    .targetCalorieAdjustment(200)
                    .build();

            when(goalRepository.existsByGoalName("Strength Building")).thenReturn(false);
            when(goalRepository.save(any(Goal.class))).thenAnswer(invocation -> {
                Goal saved = invocation.getArgument(0);
                saved.setGoalId(2L);
                return saved;
            });
            when(goalMapper.toGoalResponse(any(Goal.class))).thenReturn(
                    GoalResponse.builder()
                            .goalId(2L)
                            .goalName("Strength Building")
                            .build());

            // When
            GoalResponse result = goalService.createGoal(request);

            // Then
            assertThat(result.getGoalName()).isEqualTo("Strength Building");
            
            ArgumentCaptor<Goal> goalCaptor = ArgumentCaptor.forClass(Goal.class);
            verify(goalRepository, times(1)).save(goalCaptor.capture());
            
            Goal savedGoal = goalCaptor.getValue();
            assertThat(savedGoal.getGoalName()).isEqualTo("Strength Building");
            assertThat(savedGoal.getRecommendedRepRange()).isEqualTo("3-5");
        }

        @Test
        @DisplayName("Should throw exception for duplicate goal name")
        void createGoal_DuplicateName() {
            // Given
            CreateGoalRequest request = CreateGoalRequest.builder()
                    .goalName("Fat Loss")
                    .build();

            when(goalRepository.existsByGoalName("Fat Loss")).thenReturn(true);

            // When/Then
            assertThatThrownBy(() -> goalService.createGoal(request))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("already exists");
        }
    }

    @Nested
    @DisplayName("updateGoal (UC-16.2)")
    class UpdateGoalTests {

        @Test
        @DisplayName("Should update goal successfully")
        void updateGoal_Success() {
            // Given
            UpdateGoalRequest request = UpdateGoalRequest.builder()
                    .description("Updated description for fat loss")
                    .recommendedRepRange("15-20")
                    .targetCalorieAdjustment(-600)
                    .build();

            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(goalRepository.save(any(Goal.class))).thenReturn(mockGoal);
            when(goalMapper.toGoalResponse(any(Goal.class))).thenReturn(mockGoalResponse);

            // When
            GoalResponse result = goalService.updateGoal(1L, request);

            // Then
            assertThat(result).isNotNull();
            verify(goalRepository, times(1)).save(any(Goal.class));
            assertThat(mockGoal.getDescription()).isEqualTo("Updated description for fat loss");
            assertThat(mockGoal.getRecommendedRepRange()).isEqualTo("15-20");
            assertThat(mockGoal.getTargetCalorieAdjustment()).isEqualTo(-600);
        }

        @Test
        @DisplayName("Should update goal name successfully when not duplicate")
        void updateGoal_NameChange_Success() {
            // Given
            UpdateGoalRequest request = UpdateGoalRequest.builder()
                    .goalName("Weight Loss Pro")
                    .build();

            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(goalRepository.existsByGoalName("Weight Loss Pro")).thenReturn(false);
            when(goalRepository.save(any(Goal.class))).thenReturn(mockGoal);
            when(goalMapper.toGoalResponse(any(Goal.class))).thenReturn(mockGoalResponse);

            // When
            goalService.updateGoal(1L, request);

            // Then
            assertThat(mockGoal.getGoalName()).isEqualTo("Weight Loss Pro");
        }

        @Test
        @DisplayName("Should throw exception when goal not found")
        void updateGoal_NotFound() {
            // Given
            when(goalRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> goalService.updateGoal(999L, new UpdateGoalRequest()))
                    .isInstanceOf(ResourceNotFoundException.class);
        }

        @Test
        @DisplayName("Should throw exception for duplicate name on update")
        void updateGoal_DuplicateName() {
            // Given
            UpdateGoalRequest request = UpdateGoalRequest.builder()
                    .goalName("Muscle Gain")
                    .build();

            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(goalRepository.existsByGoalName("Muscle Gain")).thenReturn(true);

            // When/Then
            assertThatThrownBy(() -> goalService.updateGoal(1L, request))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("already exists");
        }
    }

    @Nested
    @DisplayName("deleteGoal (UC-16.2)")
    class DeleteGoalTests {

        @Test
        @DisplayName("Should delete goal when not in use")
        void deleteGoal_Success() {
            // Given
            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(false);
            when(userRepository.existsByPrimaryGoalGoalId(1L)).thenReturn(false);

            // When
            goalService.deleteGoal(1L);

            // Then
            verify(goalRepository, times(1)).delete(mockGoal);
        }

        @Test
        @DisplayName("Should throw exception when goal is in use by workout plans")
        void deleteGoal_InUseByPlans() {
            // Given
            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(true);

            // When/Then
            assertThatThrownBy(() -> goalService.deleteGoal(1L))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("in use");
        }

        @Test
        @DisplayName("Should throw exception when goal is in use by users")
        void deleteGoal_InUseByUsers() {
            // Given
            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(false);
            when(userRepository.existsByPrimaryGoalGoalId(1L)).thenReturn(true);

            // When/Then
            assertThatThrownBy(() -> goalService.deleteGoal(1L))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("in use");
        }

        @Test
        @DisplayName("Should throw exception when goal not found")
        void deleteGoal_NotFound() {
            // Given
            when(goalRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> goalService.deleteGoal(999L))
                    .isInstanceOf(ResourceNotFoundException.class);
        }
    }

    @Nested
    @DisplayName("isGoalInUse (UC-16.2)")
    class IsGoalInUseTests {

        @Test
        @DisplayName("Should return true when goal is used by plans")
        void isGoalInUse_UsedByPlans() {
            // Given
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(true);

            // When
            boolean result = goalService.isGoalInUse(1L);

            // Then
            assertThat(result).isTrue();
        }

        @Test
        @DisplayName("Should return true when goal is used by users")
        void isGoalInUse_UsedByUsers() {
            // Given
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(false);
            when(userRepository.existsByPrimaryGoalGoalId(1L)).thenReturn(true);

            // When
            boolean result = goalService.isGoalInUse(1L);

            // Then
            assertThat(result).isTrue();
        }

        @Test
        @DisplayName("Should return false when goal is not in use")
        void isGoalInUse_NotInUse() {
            // Given
            when(workoutPlanRepository.existsByGoalGoalId(1L)).thenReturn(false);
            when(userRepository.existsByPrimaryGoalGoalId(1L)).thenReturn(false);

            // When
            boolean result = goalService.isGoalInUse(1L);

            // Then
            assertThat(result).isFalse();
        }
    }
}
