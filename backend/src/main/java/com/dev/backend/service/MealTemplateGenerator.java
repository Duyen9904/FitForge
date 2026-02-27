package com.dev.backend.service;

import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionPlan;

import java.util.List;

/**
 * Service for generating meal templates based on nutrition plan parameters
 * Implements progressive loading: Day 1 initially, Day 2+ on-demand
 */
public interface MealTemplateGenerator {

    /**
     * Generate meal templates for a specific day
     * @param plan the nutrition plan
     * @param dayNumber day number (1-based)
     * @return list of meal templates (Breakfast, Lunch, Dinner)
     */
    List<MealTemplate> generateDayMeals(NutritionPlan plan, int dayNumber);

    /**
     * Regenerate a specific meal with a different recipe
     * @param plan the nutrition plan
     * @param mealType meal type (BREAKFAST, LUNCH, DINNER)
     * @param dayNumber day number (1-based)
     * @return new meal template
     */
    MealTemplate regenerateMeal(NutritionPlan plan, String mealType, int dayNumber);
}
