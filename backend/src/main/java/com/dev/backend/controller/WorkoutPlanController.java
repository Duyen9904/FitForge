package com.dev.backend.controller;

import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.request.CreateSessionExerciseRequest;
import com.dev.backend.model.dto.request.CreateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.CreateWorkoutSessionRequest;
import com.dev.backend.model.dto.request.GenerateAIPlanRequest;
import com.dev.backend.model.dto.request.GenerateRecommendedPlanRequest;
import com.dev.backend.model.dto.request.RescheduleWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.WorkoutPlanDetailResponse;
import com.dev.backend.model.dto.response.WorkoutPlanResponse;
import com.dev.backend.model.dto.response.WorkoutPlanStatsResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryResponse;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.dto.response.WorkoutTemplateSummaryResponse;
import com.dev.backend.model.entity.WorkoutPlan;

import java.util.List;
import com.dev.backend.service.WorkoutPlanService;
import com.dev.backend.service.WorkoutRecommendationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workout-plans")
@Tag(name = "Workout Plans", description = "Workout plan management endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class WorkoutPlanController {

    private final WorkoutPlanService workoutPlanService;
    private final WorkoutRecommendationService workoutRecommendationService;
    private final WorkoutPlanMapper workoutPlanMapper;

    public WorkoutPlanController(WorkoutPlanService workoutPlanService,
                                 WorkoutRecommendationService workoutRecommendationService,
                                 WorkoutPlanMapper workoutPlanMapper) {
        this.workoutPlanService = workoutPlanService;
        this.workoutRecommendationService = workoutRecommendationService;
        this.workoutPlanMapper = workoutPlanMapper;
    }

    @Operation(summary = "Create a new workout plan", description = "UC-2.1: Manually create a customized workout plan")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutPlanResponse> createPlan(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreateWorkoutPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanResponse response = workoutPlanService.createPlan(userId, request);
        return ApiResponse.success(response, "Workout plan created successfully");
    }

    @Operation(summary = "Generate AI-powered workout plan", description = "UC-2.2: Generate a workout plan using AI recommendations")
    @PostMapping("/generate")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutPlanResponse> generateAIPlan(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody GenerateAIPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanResponse response = workoutPlanService.generateAIPlan(userId, request);
        return ApiResponse.success(response, "AI workout plan generated successfully");
    }

    @Operation(summary = "Generate recommended workout plan",
               description = "Generate a workout plan based on onboarding profile using rule-based matching and template ranking")
    @PostMapping("/generate/recommended")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutPlanDetailResponse> generateRecommendedPlan(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody GenerateRecommendedPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlan plan = workoutRecommendationService.generateInitialPlan(userId, request.getStartDate());
        WorkoutPlanDetailResponse response = workoutPlanMapper.toDetailResponse(plan);
        return ApiResponse.success(response, "Workout plan generated successfully");
    }

    @Operation(summary = "Adjust workout plan based on behavior",
               description = "Analyze recent workout logs (adherence, RPE, pain flags) and adjust the plan accordingly")
    @PostMapping("/{planId}/adjust")
    public ApiResponse<WorkoutPlanResponse> adjustPlanBasedOnBehavior(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlan plan = workoutRecommendationService.adjustPlanBasedOnBehavior(userId, planId);
        WorkoutPlanResponse response = workoutPlanMapper.toResponse(plan);
        return ApiResponse.success(response, "Workout plan adjusted based on behavior");
    }

    @Operation(summary = "Add a session to a workout plan",
               description = "Add a session (optionally with exercises) to an existing plan. Supports batch add of exercises in the same request.")
    @PostMapping("/{planId}/sessions")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutSessionResponse> addSession(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @Valid @RequestBody CreateWorkoutSessionRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSessionResponse response = workoutPlanService.addSession(userId, planId, request);
        return ApiResponse.success(response, "Session added successfully");
    }

    @Operation(summary = "Add exercises to a session",
               description = "Add one or more exercises to an existing session (batch add).")
    @PostMapping("/{planId}/sessions/{sessionId}/exercises")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutSessionResponse> addExercises(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId,
            @Valid @RequestBody List<CreateSessionExerciseRequest> exercises) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSessionResponse response = workoutPlanService.addExercises(userId, planId, sessionId, exercises);
        return ApiResponse.success(response, "Exercises added successfully");
    }

    @Operation(summary = "Reschedule upcoming workout session",
               description = "Move an upcoming (not-yet-missed) session to a new date within the same workout plan.")
    @PutMapping("/{planId}/sessions/{sessionId}/reschedule")
    public ApiResponse<WorkoutSessionResponse> rescheduleSession(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId,
            @Valid @RequestBody RescheduleWorkoutSessionRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSessionResponse response = workoutPlanService.rescheduleSession(userId, planId, sessionId, request);
        return ApiResponse.success(response, "Workout session rescheduled successfully");
    }

    @Operation(summary = "Update a workout session",
               description = "Update session-level metadata (name, focus area, notes, rest day, etc.). Performs a partial update; null fields are ignored.")
    @PutMapping("/{planId}/sessions/{sessionId}")
    public ApiResponse<WorkoutSessionResponse> updateSession(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId,
            @Valid @RequestBody UpdateWorkoutSessionRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSessionResponse response = workoutPlanService.updateSession(userId, planId, sessionId, request);
        return ApiResponse.success(response, "Workout session updated successfully");
    }

    @Operation(summary = "Update an exercise in a session",
               description = "Update a single session exercise within a workout plan session. Performs a partial update; null fields are ignored.")
    @PutMapping("/{planId}/sessions/{sessionId}/exercises/{sessionExerciseId}")
    public ApiResponse<WorkoutSessionResponse> updateSessionExercise(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId,
            @PathVariable Long sessionExerciseId,
            @Valid @RequestBody UpdateSessionExerciseRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSessionResponse response = workoutPlanService.updateSessionExercise(userId, planId, sessionId, sessionExerciseId, request);
        return ApiResponse.success(response, "Session exercise updated successfully");
    }

    @Operation(summary = "Update an existing workout plan", description = "UC-2.3: Modify existing workout plan details, sessions, or exercises")
    @PutMapping("/{planId}")
    public ApiResponse<WorkoutPlanResponse> updatePlan(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @Valid @RequestBody UpdateWorkoutPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanResponse response = workoutPlanService.updatePlan(userId, planId, request);
        return ApiResponse.success(response, "Workout plan updated successfully");
    }

    @Operation(summary = "Get workout plan details", description = "UC-2.4: View plan metadata including startDate and computed endDate. Sessions are fetched separately via the week endpoint.")
    @GetMapping("/{planId}")
    public ApiResponse<WorkoutPlanDetailResponse> getPlanById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanDetailResponse response = workoutPlanService.getPlanById(userId, planId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get sessions for a specific week",
               description = "Returns all 7 sessions (with full exercise data and isCompleted) for the given week number. Sessions are generated on-demand if they do not yet exist.")
    @GetMapping("/{planId}/sessions/week/{weekNumber}")
    public ApiResponse<List<WorkoutSessionResponse>> getSessionsForWeek(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @Parameter(description = "Week number (1-based, up to plan's durationWeeks)")
            @PathVariable int weekNumber) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<WorkoutSessionResponse> response = workoutRecommendationService.getWeekSessionsWithCompletion(userId, planId, weekNumber);
        return ApiResponse.success(response, "Week " + weekNumber + " sessions retrieved successfully");
    }

    @Operation(summary = "Toggle workout plan active status", description = "UC-2.5: Activate or deactivate a workout plan")
    @PatchMapping("/{planId}/toggle-active")
    public ApiResponse<WorkoutPlanResponse> togglePlanActive(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanResponse response = workoutPlanService.togglePlanActive(userId, planId);
        return ApiResponse.success(response, "Workout plan status updated successfully");
    }

    @Operation(summary = "Delete a workout plan", description = "UC-2.6: Permanently remove a workout plan and all associated data")
    @DeleteMapping("/{planId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deletePlan(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId) {
        Long userId = Long.parseLong(jwt.getSubject());
        workoutPlanService.deletePlan(userId, planId);
        return ApiResponse.success(null, "Workout plan deleted successfully");
    }

    @Operation(summary = "Delete a workout session",
               description = "Remove a session and all its exercises from a workout plan.")
    @DeleteMapping("/{planId}/sessions/{sessionId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteSession(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId) {
        Long userId = Long.parseLong(jwt.getSubject());
        workoutPlanService.deleteSession(userId, planId, sessionId);
        return ApiResponse.success(null, "Workout session deleted successfully");
    }

    @Operation(summary = "Delete an exercise from a session",
               description = "Remove a single session exercise from a workout session within a workout plan.")
    @DeleteMapping("/{planId}/sessions/{sessionId}/exercises/{sessionExerciseId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteSessionExercise(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable Long sessionId,
            @PathVariable Long sessionExerciseId) {
        Long userId = Long.parseLong(jwt.getSubject());
        workoutPlanService.deleteSessionExercise(userId, planId, sessionId, sessionExerciseId);
        return ApiResponse.success(null, "Session exercise deleted successfully");
    }

    @Operation(summary = "Duplicate a workout plan", description = "UC-2.7: Create a copy of an existing workout plan")
    @PostMapping("/{planId}/duplicate")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutPlanResponse> duplicatePlan(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @Parameter(description = "Optional new name for the duplicated plan")
            @RequestParam(required = false) String newPlanName) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanResponse response = workoutPlanService.duplicatePlan(userId, planId, newPlanName);
        return ApiResponse.success(response, "Workout plan duplicated successfully");
    }

    @Operation(summary = "Get user workout plans", description = "Get a paginated list of workout plans for the authenticated user. Use activeOnly=true to filter to active plans only.")
    @GetMapping
    public ApiResponse<Page<WorkoutPlanSummaryResponse>> getUserPlans(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "When true, returns only active plans")
            @RequestParam(required = false) Boolean activeOnly,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<WorkoutPlanSummaryResponse> response = workoutPlanService.getUserPlans(userId, activeOnly, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get workout plan stats", description = "Get aggregate stats for the authenticated user's workout plans including total plans, active plans, completed workouts, and current streak")
    @GetMapping("/summary")
    public ApiResponse<WorkoutPlanStatsResponse> getPlanStats(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutPlanStatsResponse response = workoutPlanService.getPlanStats(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Filter workout plans", description = "UC-14.2: Filter workout plans by various criteria including active status, fitness goal, target muscle group, AI-generated flag, and date range")
    @GetMapping("/filter")
    public ApiResponse<Page<WorkoutPlanSummaryResponse>> filterPlans(
            @AuthenticationPrincipal Jwt jwt,
            @ModelAttribute com.dev.backend.model.dto.request.WorkoutPlanFilterRequest filter,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<WorkoutPlanSummaryResponse> response = workoutPlanService.filterPlans(userId, filter, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get recommended workout templates",
               description = "Return a list of recommended workout templates for the authenticated user based on their profile.")
    @GetMapping("/templates/recommended")
    public ApiResponse<List<WorkoutTemplateSummaryResponse>> getRecommendedTemplates(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Maximum number of templates to return (default 5)")
            @RequestParam(name = "limit", required = false, defaultValue = "5") int limit) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<WorkoutTemplateSummaryResponse> response = workoutRecommendationService.getRecommendedTemplates(userId, limit);
        return ApiResponse.success(response);
    }
}

