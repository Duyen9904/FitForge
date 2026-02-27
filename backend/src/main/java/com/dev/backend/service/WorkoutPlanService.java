package com.dev.backend.service;

import com.dev.backend.model.dto.request.CreateSessionExerciseRequest;
import com.dev.backend.model.dto.request.CreateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.CreateWorkoutSessionRequest;
import com.dev.backend.model.dto.request.GenerateAIPlanRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.request.RescheduleWorkoutSessionRequest;
import com.dev.backend.model.dto.request.WorkoutPlanFilterRequest;
import com.dev.backend.model.dto.response.WorkoutPlanDetailResponse;
import com.dev.backend.model.dto.response.WorkoutPlanResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryResponse;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface WorkoutPlanService {

    /**
     * Create a new workout plan manually (UC-2.1)
     */
    WorkoutPlanResponse createPlan(Long userId, CreateWorkoutPlanRequest request);

    /**
     * Generate an AI-powered workout plan (UC-2.2)
     */
    WorkoutPlanResponse generateAIPlan(Long userId, GenerateAIPlanRequest request);

    /**
     * Update an existing workout plan (UC-2.3)
     */
    WorkoutPlanResponse updatePlan(Long userId, Long planId, UpdateWorkoutPlanRequest request);

    /**
     * Add a session to a workout plan.
     * Supports optional exercises in the same request (batch add).
     */
    WorkoutSessionResponse addSession(Long userId, Long planId, CreateWorkoutSessionRequest request);

    /**
     * Add one or more exercises to an existing session (batch add).
     */
    WorkoutSessionResponse addExercises(Long userId, Long planId, Long sessionId, List<CreateSessionExerciseRequest> exercises);

    /**
     * Get workout plan details (UC-2.4)
     */
    WorkoutPlanDetailResponse getPlanById(Long userId, Long planId);

    /**
     * Toggle workout plan active status (UC-2.5)
     */
    WorkoutPlanResponse togglePlanActive(Long userId, Long planId);

    /**
     * Delete a workout plan (UC-2.6)
     */
    void deletePlan(Long userId, Long planId);

    /**
     * Duplicate an existing workout plan (UC-2.7)
     */
    WorkoutPlanResponse duplicatePlan(Long userId, Long planId, String newPlanName);

    /**
     * Get workout plans for a user with pagination.
     * When activeOnly is true, returns only active plans; otherwise returns all plans.
     */
    Page<WorkoutPlanSummaryResponse> getUserPlans(Long userId, Boolean activeOnly, Pageable pageable);

    /**
     * Filter workout plans (UC-14.2)
     */
    Page<WorkoutPlanSummaryResponse> filterPlans(Long userId, WorkoutPlanFilterRequest filter, Pageable pageable);

    /**
     * Reschedule an upcoming (not-yet-missed) workout session to a new date.
     * This updates the session's scheduledDate (and synchronizes dayNumber)
     * while enforcing plan ownership and date constraints.
     */
    WorkoutSessionResponse rescheduleSession(Long userId, Long planId, Long sessionId, RescheduleWorkoutSessionRequest request);

    /**
     * Update a single exercise within a workout session.
     * This performs a partial update of the SessionExercise fields; any null fields
     * in the request are ignored and leave existing values unchanged.
     */
    WorkoutSessionResponse updateSessionExercise(Long userId,
                                                 Long planId,
                                                 Long sessionId,
                                                 Long sessionExerciseId,
                                                 UpdateSessionExerciseRequest request);

    /**
     * Delete a single exercise from a workout session.
     * Does not modify other exercises in the session.
     */
    void deleteSessionExercise(Long userId,
                               Long planId,
                               Long sessionId,
                               Long sessionExerciseId);
}

