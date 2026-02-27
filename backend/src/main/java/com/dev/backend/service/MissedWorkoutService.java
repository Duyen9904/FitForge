package com.dev.backend.service;

import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.request.SelectMakeupOptionRequest;
import com.dev.backend.model.dto.response.MakeupWorkoutOptionResponse;
import com.dev.backend.model.dto.response.MakeupWorkoutResponse;
import com.dev.backend.model.dto.response.MissedWorkoutReportResponse;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.List;

/**
 * Service interface for missed workout management (UC-6)
 */
public interface MissedWorkoutService {

    /**
     * Generate makeup workout options (UC-6.2)
     */
    List<MakeupWorkoutOptionResponse> generateMakeupOptions(Long userId, Long missedWorkoutId);

    /**
     * Select and apply a makeup option (UC-6.2)
     */
    MissedWorkoutResponse selectMakeupOption(Long userId, Long missedWorkoutId, SelectMakeupOptionRequest request);

    /**
     * Reschedule a missed workout (UC-6.3)
     */
    MissedWorkoutResponse rescheduleMissedWorkout(Long userId, Long missedWorkoutId, RescheduleMissedWorkoutRequest request);

    /**
     * Get a specific missed workout
     */
    MissedWorkoutResponse getMissedWorkout(Long userId, Long missedWorkoutId);

    /**
     * Get all missed workouts for a user
     */
    Page<MissedWorkoutResponse> getMissedWorkouts(Long userId, Pageable pageable);

    /**
     * Get unaddressed missed workouts
     */
    List<MissedWorkoutResponse> getUnaddressedMissedWorkouts(Long userId);

    /**
     * Generate missed workout consistency report (UC-6.4)
     */
    MissedWorkoutReportResponse getMissedWorkoutReport(Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * Get all active (incomplete) makeup workouts for a user
     */
    List<MakeupWorkoutResponse> getActiveMakeupWorkouts(Long userId);

    /**
     * Detect and log missed workouts for a given date. Used by the daily cron job.
     * Creates MissedWorkout records for scheduled sessions that were not completed.
     */
    void detectAndLogMissedWorkoutsForDate(LocalDate date);
}
