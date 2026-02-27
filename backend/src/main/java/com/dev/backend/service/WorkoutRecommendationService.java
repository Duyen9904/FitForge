package com.dev.backend.service;

import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.dto.response.WorkoutTemplateSummaryResponse;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.model.entity.WorkoutSession;

import java.time.LocalDate;
import java.util.List;

/**
 * High-level service for generating and adjusting workout plans
 * based on user profile and behavior data.
 */
public interface WorkoutRecommendationService {

    /**
     * Generate an initial workout plan for a user based on their onboarding profile.
     * @param userId the user ID
     * @param startDate the start date for the workout plan
     * @return the newly generated WorkoutPlan with Day 1-3 sessions
     */
    WorkoutPlan generateInitialPlan(Long userId, LocalDate startDate);

    /**
     * Adjust a workout plan based on recent behavior (adherence, RPE, pain flags).
     * @param userId the user ID
     * @param planId the plan to adjust
     * @return the adjusted or new WorkoutPlan
     */
    WorkoutPlan adjustPlanBasedOnBehavior(Long userId, Long planId);

    /**
     * Get or generate a workout session for a specific day on-demand.
     * @param userId the user ID
     * @param planId the plan ID
     * @param dayNumber the day number (1-based)
     * @return the workout session
     */
    WorkoutSession getOrGenerateSessionForDay(Long userId, Long planId, int dayNumber);

    /**
     * Get or generate all 7 sessions for a specific week of a plan.
     * Sessions are lazy-generated and saved if they do not yet exist.
     * @param userId the user ID
     * @param planId the plan ID
     * @param weekNumber the week number (1-based, max = durationWeeks)
     * @return list of 7 WorkoutSession objects for that week
     */
    List<WorkoutSession> getOrGenerateSessionsForWeek(Long userId, Long planId, int weekNumber);

    /**
     * Get or generate all 7 sessions for a specific week of a plan with completion status.
     * @param userId the user ID
     * @param planId the plan ID
     * @param weekNumber the week number (1-based, max = durationWeeks)
     * @return list of 7 WorkoutSessionResponse objects with isCompleted populated
     */
    List<WorkoutSessionResponse> getWeekSessionsWithCompletion(Long userId, Long planId, int weekNumber);

    /**
     * Get top recommended workout templates for a user based on their profile.
     * @param userId the user ID
     * @param limit maximum number of templates to return
     * @return list of template summaries sorted by relevance
     */
    List<WorkoutTemplateSummaryResponse> getRecommendedTemplates(Long userId, int limit);
}
