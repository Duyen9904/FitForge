package com.dev.backend.service.impl;

import com.dev.backend.model.entity.WorkoutSession;
import com.dev.backend.repository.WorkoutSessionRepository;
import com.dev.backend.service.MissedWorkoutService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class MissedWorkoutScheduler {

    private static final Logger logger = LoggerFactory.getLogger(MissedWorkoutScheduler.class);

    private final MissedWorkoutService missedWorkoutService;
    private final WorkoutSessionRepository workoutSessionRepository;

    @Value("${missed-workout.scheduler.enabled:true}")
    private boolean schedulerEnabled;

    @Value("${missed-workout.scheduler.catchup-on-startup:false}")
    private boolean catchupOnStartup;

    @Value("${missed-workout.scheduler.catchup-days:7}")
    private int catchupDays;

    public MissedWorkoutScheduler(MissedWorkoutService missedWorkoutService,
                                  WorkoutSessionRepository workoutSessionRepository) {
        this.missedWorkoutService = missedWorkoutService;
        this.workoutSessionRepository = workoutSessionRepository;
    }

    /**
     * On application startup, catch up on any missed cron runs
     * by scanning the last N days (default 7).
     * This handles the case where the server was down and the daily cron never fired.
     * The detectAndLogMissedWorkoutsForDate method is idempotent,
     * so re-processing an already-processed date is safe.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void catchUpMissedWorkouts() {
        if (!schedulerEnabled || !catchupOnStartup) {
            return;
        }

        logger.info("Startup catch-up: checking missed workouts for the last {} days", catchupDays);
        LocalDate today = LocalDate.now();

        for (int i = 1; i <= catchupDays; i++) {
            LocalDate targetDate = today.minusDays(i);
            try {
                missedWorkoutService.detectAndLogMissedWorkoutsForDate(targetDate);
            } catch (Exception ex) {
                logger.error("Startup catch-up error for {}: {}", targetDate, ex.getMessage(), ex);
            }
        }

        logger.info("Startup catch-up completed");
    }

    /**
     * Daily job to auto-detect and log missed workouts for the previous day.
     */
    @Scheduled(cron = "${missed-workout.scheduler.cron:0 0 1 * * *}")
    public void checkMissedWorkouts() {
        if (!schedulerEnabled) {
            return;
        }

        LocalDate targetDate = LocalDate.now().minusDays(1);
        logger.info("Running missed workout detection for date {}", targetDate);

        try {
            missedWorkoutService.detectAndLogMissedWorkoutsForDate(targetDate);
        } catch (Exception ex) {
            logger.error("Error during missed workout detection for {}: {}", targetDate, ex.getMessage(), ex);
        }
    }
}

