package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class GoalMapperTest {

    private GoalMapper goalMapper;

    @BeforeEach
    void setUp() {
        goalMapper = new GoalMapper();
    }

    @Test
    @DisplayName("Should map Goal entity to GoalResponse correctly")
    void toGoalResponse_Success() {
        // Given
        Goal goal = new Goal();
        goal.setGoalId(1L);
        goal.setGoalName("Slimfit");
        goal.setDescription("Reduce body fat percentage");

        // When
        GoalResponse response = goalMapper.toGoalResponse(goal);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getGoalId()).isEqualTo(1L);
        assertThat(response.getGoalName()).isEqualTo("Slimfit");
        assertThat(response.getDescription()).isEqualTo("Reduce body fat percentage");
    }

    @Test
    @DisplayName("Should handle null values gracefully")
    void toGoalResponse_NullValues() {
        // Given
        Goal goal = new Goal();
        goal.setGoalId(2L);
        goal.setGoalName("Bodybuilding");

        // When
        GoalResponse response = goalMapper.toGoalResponse(goal);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getGoalId()).isEqualTo(2L);
        assertThat(response.getGoalName()).isEqualTo("Bodybuilding");
        assertThat(response.getDescription()).isNull();
    }
}
