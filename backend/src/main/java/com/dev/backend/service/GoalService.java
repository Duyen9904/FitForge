package com.dev.backend.service;

import com.dev.backend.model.dto.request.CreateGoalRequest;
import com.dev.backend.model.dto.request.UpdateGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;

import java.util.List;

public interface GoalService {

    /**
     * Get all fitness goal templates (UC-12.1)
     */
    List<GoalResponse> getAllGoals();

    /**
     * Get a specific goal by ID
     */
    GoalResponse getGoalById(Long goalId);

    // ============= Admin Methods (UC-16.2) =============

    /**
     * Create a new goal template - admin only (UC-16.2)
     */
    GoalResponse createGoal(CreateGoalRequest request);

    /**
     * Update a goal template - admin only (UC-16.2)
     */
    GoalResponse updateGoal(Long goalId, UpdateGoalRequest request);

    /**
     * Delete a goal template - admin only (UC-16.2)
     * @throws IllegalStateException if goal is in use
     */
    void deleteGoal(Long goalId);

    /**
     * Check if a goal is in use (by users or workout plans)
     */
    boolean isGoalInUse(Long goalId);
}
