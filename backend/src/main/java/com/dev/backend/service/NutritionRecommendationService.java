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
     * @return the newly generated NutritionPlan with Day 1 meals
     */
    NutritionPlan generateInitialPlan(Long userId);

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
}
