package com.dev.backend.service;

import com.dev.backend.model.dto.request.CompleteWorkoutRequest;
import com.dev.backend.model.dto.request.LogExerciseRequest;
import com.dev.backend.model.dto.request.SkipExerciseRequest;
import com.dev.backend.model.dto.request.StartWorkoutRequest;
import com.dev.backend.model.dto.response.HomeDashboardResponse;
import com.dev.backend.model.dto.response.ProgressChartResponse;
import com.dev.backend.model.dto.response.WeeklyWorkoutProgressResponse;
import com.dev.backend.model.dto.response.WorkoutHistoryResponse;
import com.dev.backend.model.dto.response.WorkoutProgressResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;
import java.time.LocalDate;

public interface WorkoutExecutionService {

    /**
     * Start a workout session (UC-5.1)
     */
    WorkoutProgressResponse startWorkout(Long userId, StartWorkoutRequest request);

    /**
     * Log exercise performance (UC-5.2)
     */
    WorkoutProgressResponse logExercise(Long userId, Long progressId, LogExerciseRequest request);

    /**
     * Complete workout session (UC-5.3)
     */
    WorkoutProgressResponse completeWorkout(Long userId, Long progressId, CompleteWorkoutRequest request);

    /**
     * Skip an exercise during workout (UC-5.4)
     */
    WorkoutProgressResponse skipExercise(Long userId, Long progressId, SkipExerciseRequest request);

    /**
     * Get workout history (UC-5.5)
     */
    Page<WorkoutHistoryResponse> getWorkoutHistory(Long userId, Instant startDate, Instant endDate, Pageable pageable);

    /**
     * Get progress charts data (UC-5.6)
     */
    ProgressChartResponse getProgressCharts(Long userId, Instant startDate, Instant endDate, Long exerciseId);

    /**
     * Get current in-progress workout
     */
    WorkoutProgressResponse getCurrentWorkout(Long userId);

    /**
     * Get workout progress by ID
     */
    WorkoutProgressResponse getWorkoutById(Long userId, Long progressId);

    /**
     * Cancel/abandon current workout
     */
    void cancelWorkout(Long userId, Long progressId);

    /**
     * Get weekly workout progress for visualization
     */
    WeeklyWorkoutProgressResponse getWeeklyProgress(Long userId, LocalDate startDate);

    /**
     * Get aggregated home dashboard data
     */
    HomeDashboardResponse getDashboard(Long userId, LocalDate referenceDate);
}
