package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.GoalMapper;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.repository.GoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GoalServiceImplTest {

    @Mock
    private GoalRepository goalRepository;

    @Mock
    private GoalMapper goalMapper;

    @InjectMocks
    private GoalServiceImpl goalService;

    private Goal mockGoal;
    private GoalResponse mockGoalResponse;

    @BeforeEach
    void setUp() {
        mockGoal = new Goal();
        mockGoal.setGoalId(1L);
        mockGoal.setGoalName("Slimfit");
        mockGoal.setDescription("Reduce body fat");

        mockGoalResponse = GoalResponse.builder()
                .goalId(1L)
                .goalName("Slimfit")
                .description("Reduce body fat")
                .build();
    }

    @Nested
    @DisplayName("getAllGoals")
    class GetAllGoalsTests {

        @Test
        @DisplayName("Should return all goals")
        void getAllGoals_Success() {
            // Given
            Goal goal2 = new Goal();
            goal2.setGoalId(2L);
            goal2.setGoalName("Bodybuilding");

            GoalResponse response2 = GoalResponse.builder()
                    .goalId(2L)
                    .goalName("Bodybuilding")
                    .build();

            when(goalRepository.findAll()).thenReturn(Arrays.asList(mockGoal, goal2));
            when(goalMapper.toGoalResponse(mockGoal)).thenReturn(mockGoalResponse);
            when(goalMapper.toGoalResponse(goal2)).thenReturn(response2);

            // When
            List<GoalResponse> result = goalService.getAllGoals();

            // Then
            assertThat(result).hasSize(2);
            assertThat(result.get(0).getGoalName()).isEqualTo("Slimfit");
            assertThat(result.get(1).getGoalName()).isEqualTo("Bodybuilding");
            verify(goalRepository, times(1)).findAll();
        }

        @Test
        @DisplayName("Should return empty list when no goals exist")
        void getAllGoals_Empty() {
            // Given
            when(goalRepository.findAll()).thenReturn(List.of());

            // When
            List<GoalResponse> result = goalService.getAllGoals();

            // Then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getGoalById")
    class GetGoalByIdTests {

        @Test
        @DisplayName("Should return goal by ID")
        void getGoalById_Success() {
            // Given
            when(goalRepository.findById(1L)).thenReturn(Optional.of(mockGoal));
            when(goalMapper.toGoalResponse(mockGoal)).thenReturn(mockGoalResponse);

            // When
            GoalResponse result = goalService.getGoalById(1L);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getGoalId()).isEqualTo(1L);
            assertThat(result.getGoalName()).isEqualTo("Slimfit");
            verify(goalRepository, times(1)).findById(1L);
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when goal not found")
        void getGoalById_NotFound() {
            // Given
            when(goalRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> goalService.getGoalById(999L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Goal not found");

            verify(goalRepository, times(1)).findById(999L);
        }
    }
}
