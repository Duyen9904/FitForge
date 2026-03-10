package com.dev.backend.service;

import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionPlan;

import java.util.List;

/**
 * High-level service for generating and adjusting nutrition plans
 * based on user profile and behavior data.
 */
public interface NutritionRecommendationService {

    /**
     * Generate an initial nutrition plan for a user based on their onboarding profile.
     * @param userId the user ID
     * @param totalDays number of days in the plan cycle (1-7)
     * @return the newly generated NutritionPlan with NutritionDays and DayMeals
     */
    NutritionPlan generateInitialPlan(Long userId, int totalDays);

    /**
     * Adjust a nutrition plan based on adherence and weight trend.
     * @param userId the user ID
     * @param planId the plan to adjust
     * @return the adjusted NutritionPlan
     */
    NutritionPlan adjustPlanBasedOnBehavior(Long userId, Long planId);

    /**
     * Get or generate meals for a specific day on-demand.
     * @param userId the user ID
     * @param planId the plan ID
     * @param dayNumber the day number (1-based)
     * @return list of meal templates for that day
     */
    List<MealTemplate> getOrGenerateMealsForDay(Long userId, Long planId, int dayNumber);

    /**
     * Generate a nutrition plan using AI (OpenRouter).
     * @param userId the user ID
     * @param totalDays number of days in the plan cycle (1-7)
     * @return the AI-generated NutritionPlan with NutritionDays and DayMeals
     */
    NutritionPlan generateAiPlan(Long userId, int totalDays);

    /**
     * Adjust a nutrition plan using AI based on adherence and weight trends.
     * @param userId the user ID
     * @param planId the plan to adjust
     * @return the AI-adjusted NutritionPlan
     */
    NutritionPlan adjustPlanWithAi(Long userId, Long planId);
}
