package com.dev.backend.service;

import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.model.entity.WorkoutSession;

import java.util.List;

/**
 * Service for generating workout sessions based on plan parameters
 * Implements progressive loading: Day 1-3 initially, Day 4+ on-demand
 */
public interface WorkoutSessionGenerator {

    /**
     * Generate workout sessions for a specific day range
     * @param plan the workout plan
     * @param exercises available exercises
     * @param startDay starting day number (1-based)
     * @param endDay ending day number (inclusive)
     * @return list of workout sessions
     */
    List<WorkoutSession> generateSessions(WorkoutPlan plan, List<Exercise> exercises, int startDay, int endDay);

    /**
     * Generate a single workout session for a specific day
     * @param plan the workout plan
     * @param exercises available exercises
     * @param dayNumber day number (1-based)
     * @return workout session
     */
    WorkoutSession generateSessionForDay(WorkoutPlan plan, List<Exercise> exercises, int dayNumber);
}
