package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.GoalMapper;
import com.dev.backend.model.dto.request.CreateGoalRequest;
import com.dev.backend.model.dto.request.UpdateGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.WorkoutPlanRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.GoalService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class GoalServiceImpl implements GoalService {

    private final GoalRepository goalRepository;
    private final GoalMapper goalMapper;
    private final WorkoutPlanRepository workoutPlanRepository;
    private final UserRepository userRepository;

    public GoalServiceImpl(GoalRepository goalRepository, GoalMapper goalMapper,
                          WorkoutPlanRepository workoutPlanRepository, UserRepository userRepository) {
        this.goalRepository = goalRepository;
        this.goalMapper = goalMapper;
        this.workoutPlanRepository = workoutPlanRepository;
        this.userRepository = userRepository;
    }

    @Override
    public List<GoalResponse> getAllGoals() {
        return goalRepository.findAll().stream()
                .map(goalMapper::toGoalResponse)
                .collect(Collectors.toList());
    }

    @Override
    public GoalResponse getGoalById(Long goalId) {
        Goal goal = goalRepository.findById(goalId)
                .orElseThrow(() -> new ResourceNotFoundException("Goal not found with id: " + goalId));
        return goalMapper.toGoalResponse(goal);
    }

    // ============= Admin Methods (UC-16.2) =============

    @Override
    @Transactional
    public GoalResponse createGoal(CreateGoalRequest request) {
        // Check for duplicate goal name
        if (goalRepository.existsByGoalName(request.getGoalName())) {
            throw new IllegalStateException("Goal with name '" + request.getGoalName() + "' already exists");
        }

        Goal goal = new Goal();
        goal.setGoalName(request.getGoalName());
        goal.setDescription(request.getDescription());
        goal.setRecommendedRepRange(request.getRecommendedRepRange());
        goal.setRecommendedRestTime(request.getRecommendedRestTime());
        goal.setRecommendedFrequency(request.getRecommendedFrequency());
        goal.setTargetCalorieAdjustment(request.getTargetCalorieAdjustment());

        Goal savedGoal = goalRepository.save(goal);
        return goalMapper.toGoalResponse(savedGoal);
    }

    @Override
    @Transactional
    public GoalResponse updateGoal(Long goalId, UpdateGoalRequest request) {
        Goal goal = goalRepository.findById(goalId)
                .orElseThrow(() -> new ResourceNotFoundException("Goal not found with id: " + goalId));

        // Update only non-null fields
        if (request.getGoalName() != null) {
            // Check for duplicate name (if different from current)
            if (!goal.getGoalName().equals(request.getGoalName()) && 
                goalRepository.existsByGoalName(request.getGoalName())) {
                throw new IllegalStateException("Goal with name '" + request.getGoalName() + "' already exists");
            }
            goal.setGoalName(request.getGoalName());
        }
        if (request.getDescription() != null) {
            goal.setDescription(request.getDescription());
        }
        if (request.getRecommendedRepRange() != null) {
            goal.setRecommendedRepRange(request.getRecommendedRepRange());
        }
        if (request.getRecommendedRestTime() != null) {
            goal.setRecommendedRestTime(request.getRecommendedRestTime());
        }
        if (request.getRecommendedFrequency() != null) {
            goal.setRecommendedFrequency(request.getRecommendedFrequency());
        }
        if (request.getTargetCalorieAdjustment() != null) {
            goal.setTargetCalorieAdjustment(request.getTargetCalorieAdjustment());
        }

        Goal savedGoal = goalRepository.save(goal);
        return goalMapper.toGoalResponse(savedGoal);
    }

    @Override
    @Transactional
    public void deleteGoal(Long goalId) {
        Goal goal = goalRepository.findById(goalId)
                .orElseThrow(() -> new ResourceNotFoundException("Goal not found with id: " + goalId));

        if (isGoalInUse(goalId)) {
            throw new IllegalStateException("Cannot delete goal that is in use by workout plans or users");
        }

        goalRepository.delete(goal);
    }

    @Override
    public boolean isGoalInUse(Long goalId) {
        // Check if any workout plans use this goal
        boolean usedByPlans = workoutPlanRepository.existsByGoalGoalId(goalId);
        // Check if any users have this as primary goal
        boolean usedByUsers = userRepository.existsByPrimaryGoalGoalId(goalId);
        return usedByPlans || usedByUsers;
    }
}
