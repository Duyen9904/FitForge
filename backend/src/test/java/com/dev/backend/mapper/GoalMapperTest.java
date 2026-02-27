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
        goal.setGoalName("Fat Loss");
        goal.setDescription("Reduce body fat percentage");
        goal.setRecommendedRepRange("12-15");
        goal.setRecommendedRestTime("60 seconds");
        goal.setRecommendedFrequency("4-5 days/week");
        goal.setTargetCalorieAdjustment(-500);

        // When
        GoalResponse response = goalMapper.toGoalResponse(goal);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getGoalId()).isEqualTo(1L);
        assertThat(response.getGoalName()).isEqualTo("Fat Loss");
        assertThat(response.getDescription()).isEqualTo("Reduce body fat percentage");
        assertThat(response.getRecommendedRepRange()).isEqualTo("12-15");
        assertThat(response.getRecommendedRestTime()).isEqualTo("60 seconds");
        assertThat(response.getRecommendedFrequency()).isEqualTo("4-5 days/week");
        assertThat(response.getTargetCalorieAdjustment()).isEqualTo(-500);
    }

    @Test
    @DisplayName("Should handle null values gracefully")
    void toGoalResponse_NullValues() {
        // Given
        Goal goal = new Goal();
        goal.setGoalId(2L);
        goal.setGoalName("Muscle Gain");

        // When
        GoalResponse response = goalMapper.toGoalResponse(goal);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getGoalId()).isEqualTo(2L);
        assertThat(response.getGoalName()).isEqualTo("Muscle Gain");
        assertThat(response.getDescription()).isNull();
        assertThat(response.getRecommendedRepRange()).isNull();
    }
}
