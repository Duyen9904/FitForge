package com.dev.backend.service;

import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Service interface for nutrition management (UC-7)
 */
public interface NutritionService {

    // ========== Nutrition Plan (UC-7.1) ==========

    /**
     * Create a new nutrition plan
     */
    NutritionPlanResponse createNutritionPlan(Long userId, CreateNutritionPlanRequest request);

    /**
     * Update existing nutrition plan
     */
    NutritionPlanResponse updateNutritionPlan(Long userId, Long planId, UpdateNutritionPlanRequest request);

    /**
     * Get active nutrition plan for user
     */
    NutritionPlanResponse getActivePlan(Long userId);

    /**
     * Delete a nutrition plan and all associated data (days, meals, templates)
     */
    void deletePlan(Long userId, Long planId);

    /**
     * Deactivate a nutrition plan (set isActive to false)
     */
    NutritionPlanResponse deactivatePlan(Long userId, Long planId);

    // ========== Meal Logging (UC-7.2, UC-7.3) ==========

    /**
     * Log a meal (free-form manual entry or from a template).
     * Creates a PlanMeal with status=COMPLETED.
     */
    PlanMealResponse logMeal(Long userId, LogMealRequest request);

    /**
     * Get daily meals (all statuses)
     */
    List<PlanMealResponse> getDailyMeals(Long userId, LocalDate date);

    /**
     * Get daily nutrition summary
     */
    DailyNutritionSummaryResponse getDailySummary(Long userId, LocalDate date);

    // ========== Cheat Meal Management (UC-7.3, UC-7.4) ==========

    /**
     * Get uncompensated cheat meals
     */
    List<CheatMealLogResponse> getUncompensatedCheatMeals(Long userId);

    /**
     * Generate compensation options for a cheat meal (UC-7.4)
     */
    List<CompensationActionResponse> generateCompensationOptions(Long userId, Long cheatMealLogId);

    /**
     * Select and apply compensation strategy (UC-7.4)
     */
    CompensationActionResponse selectCompensation(Long userId, Long cheatMealLogId, SelectCompensationRequest request);

    // ========== Nutrition Days ==========

    /**
     * Get all days in a nutrition plan with their meals
     */
    List<NutritionDayResponse> getPlanDays(Long userId, Long planId);

    /**
     * Get a specific day in a nutrition plan with its meals
     */
    NutritionDayResponse getPlanDay(Long userId, Long planId, int dayNumber);

    // ========== Meal Templates (UC-7.6) ==========

    /**
     * Get all system-provided meal templates
     */
    List<MealTemplateResponse> getMealTemplates();

    /**
     * Get a single meal template by ID
     */
    MealTemplateResponse getMealTemplateById(Long templateId);

    // ========== Weekly View ==========

    /**
     * Get daily nutrition totals for a date range (weekly calendar view).
     */
    List<DailyNutritionSummaryResponse> getWeeklyTotals(Long userId, LocalDate weekStart, LocalDate weekEnd);

    // ========== Plan Meals ==========

    /**
     * Schedule a meal template on a specific date
     */
    PlanMealResponse scheduleMeal(Long userId, ScheduleMealRequest request);

    /**
     * Mark a planned meal as completed
     */
    PlanMealResponse completePlanMeal(Long userId, Long planMealId);

    /**
     * Mark a day meal as completed
     */
    DayMealResponse completeDayMeal(Long userId, Long dayMealId);

    /**
     * Mark a planned meal as skipped
     */
    PlanMealResponse skipPlanMeal(Long userId, Long planMealId);

}
