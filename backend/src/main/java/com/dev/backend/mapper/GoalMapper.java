package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import org.springframework.stereotype.Component;

@Component
public class GoalMapper {

    public GoalResponse toGoalResponse(Goal goal) {
        if (goal == null) {
            return null;
        }
        return GoalResponse.builder()
                .goalId(goal.getGoalId())
                .goalName(goal.getGoalName())
                .description(goal.getDescription())
                .recommendedRepRange(goal.getRecommendedRepRange())
                .recommendedRestTime(goal.getRecommendedRestTime())
                .recommendedFrequency(goal.getRecommendedFrequency())
                .targetCalorieAdjustment(goal.getTargetCalorieAdjustment())
                .build();
    }
}
