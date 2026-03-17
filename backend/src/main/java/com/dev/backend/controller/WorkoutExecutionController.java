package com.dev.backend.controller;

import com.dev.backend.model.dto.request.CompleteWorkoutRequest;
import com.dev.backend.model.dto.request.LogExerciseRequest;
import com.dev.backend.model.dto.request.SkipExerciseRequest;
import com.dev.backend.model.dto.request.StartWorkoutRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.HomeDashboardResponse;
import com.dev.backend.model.dto.response.ProfileSummaryResponse;
import com.dev.backend.model.dto.response.ProgressChartResponse;
import com.dev.backend.model.dto.response.WeeklyWorkoutProgressResponse;
import com.dev.backend.model.dto.response.WorkoutHistoryResponse;
import com.dev.backend.model.dto.response.WorkoutProgressResponse;
import com.dev.backend.service.WorkoutExecutionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/workouts")
@Tag(name = "Workout Execution", description = "Workout execution and progress tracking endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class WorkoutExecutionController {

    private final WorkoutExecutionService workoutExecutionService;

    public WorkoutExecutionController(WorkoutExecutionService workoutExecutionService) {
        this.workoutExecutionService = workoutExecutionService;
    }

    @Operation(summary = "Start a workout session", description = "UC-5.1: Begin executing a scheduled workout")
    @PostMapping("/start")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<WorkoutProgressResponse> startWorkout(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody StartWorkoutRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.startWorkout(userId, request);
        return ApiResponse.success(response, "Workout started successfully");
    }

    @Operation(summary = "Log exercise performance", description = "UC-5.2: Record actual performance for each set")
    @PostMapping("/{progressId}/log")
    public ApiResponse<WorkoutProgressResponse> logExercise(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId,
            @Valid @RequestBody LogExerciseRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.logExercise(userId, progressId, request);
        return ApiResponse.success(response, "Exercise logged successfully");
    }

    @Operation(summary = "Complete workout session", description = "UC-5.3: Finish workout and provide session summary")
    @PostMapping("/{progressId}/complete")
    public ApiResponse<WorkoutProgressResponse> completeWorkout(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId,
            @Valid @RequestBody CompleteWorkoutRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.completeWorkout(userId, progressId, request);
        return ApiResponse.success(response, "Workout completed successfully");
    }

    @Operation(summary = "Upload workout proof photo", description = "Upload or replace a proof photo for a workout. Can be called before or after completing the workout.")
    @PostMapping(value = "/{progressId}/proof", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<WorkoutProgressResponse> uploadWorkoutProof(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId,
            @RequestParam("file") MultipartFile file) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.uploadWorkoutProof(userId, progressId, file);
        return ApiResponse.success(response, "Workout proof photo uploaded successfully");
    }

    @Operation(summary = "Skip exercise", description = "UC-5.4: Skip an exercise during workout with reason")
    @PostMapping("/{progressId}/skip")
    public ApiResponse<WorkoutProgressResponse> skipExercise(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId,
            @Valid @RequestBody SkipExerciseRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.skipExercise(userId, progressId, request);
        return ApiResponse.success(response, "Exercise skipped");
    }

    @Operation(summary = "Get workout history", description = "UC-5.5: View past workout sessions")
    @GetMapping("/history")
    public ApiResponse<Page<WorkoutHistoryResponse>> getWorkoutHistory(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Start date (ISO-8601)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant startDate,
            @Parameter(description = "End date (ISO-8601)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant endDate,
            @PageableDefault(size = 20, sort = "workoutDate", direction = Sort.Direction.DESC) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<WorkoutHistoryResponse> response = workoutExecutionService.getWorkoutHistory(userId, startDate, endDate, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get progress charts", description = "UC-5.6: Analyze workout performance over time")
    @GetMapping("/progress/charts")
    public ApiResponse<ProgressChartResponse> getProgressCharts(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Start date (ISO-8601)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant startDate,
            @Parameter(description = "End date (ISO-8601)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant endDate,
            @Parameter(description = "Specific exercise ID to filter by")
            @RequestParam(required = false) String exerciseId) {
        Long userId = Long.parseLong(jwt.getSubject());
        ProgressChartResponse response = workoutExecutionService.getProgressCharts(userId, startDate, endDate, exerciseId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get weekly workout progress", description = "Get daily workout progress for visualization")
    @GetMapping("/weekly-progress")
    public ApiResponse<WeeklyWorkoutProgressResponse> getWeeklyProgress(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Start date of week (defaults to current week's Sunday)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        
        // Default to current week's Sunday
        LocalDate weekStart = startDate != null 
            ? startDate 
            : LocalDate.now().with(DayOfWeek.SUNDAY);
        
        WeeklyWorkoutProgressResponse response = workoutExecutionService.getWeeklyProgress(userId, weekStart);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get current in-progress workout", description = "Get the currently active workout session if any")
    @GetMapping("/current")
    public ApiResponse<WorkoutProgressResponse> getCurrentWorkout(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.getCurrentWorkout(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get workout details by ID", description = "Get detailed workout progress information")
    @GetMapping("/{progressId}")
    public ApiResponse<WorkoutProgressResponse> getWorkoutById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutProgressResponse response = workoutExecutionService.getWorkoutById(userId, progressId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Cancel workout", description = "Cancel/abandon an in-progress workout")
    @DeleteMapping("/{progressId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> cancelWorkout(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long progressId) {
        Long userId = Long.parseLong(jwt.getSubject());
        workoutExecutionService.cancelWorkout(userId, progressId);
        return ApiResponse.success(null, "Workout cancelled");
    }

    @Operation(summary = "Get home dashboard", description = "Returns aggregated dashboard data: today's session, weekly stats, weekly progress chart, and active plans")
    @GetMapping("/dashboard")
    public ApiResponse<HomeDashboardResponse> getDashboard(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Reference date (ISO-8601, defaults to today)")
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Long userId = Long.parseLong(jwt.getSubject());
        LocalDate refDate = date != null ? date : LocalDate.now();
        HomeDashboardResponse response = workoutExecutionService.getDashboard(userId, refDate);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get profile summary", description = "Get unified profile data: activity heatmap + check-in photos")
    @GetMapping("/profile-summary")
    public ApiResponse<ProfileSummaryResponse> getProfileSummary(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Number of months for activity heatmap (default 6)")
            @RequestParam(defaultValue = "6") int months) {
        Long userId = Long.parseLong(jwt.getSubject());
        ProfileSummaryResponse response = workoutExecutionService.getProfileSummary(userId, months);
        return ApiResponse.success(response);
    }
}
