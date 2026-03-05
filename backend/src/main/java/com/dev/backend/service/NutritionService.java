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

    // ========== Meal Logging (UC-7.2, UC-7.3) ==========

    /**
     * Log a meal (UC-7.2)
     */
    NutritionLogResponse logMeal(Long userId, LogMealRequest request);

    /**
     * Log meal from template (UC-7.7)
     */
    NutritionLogResponse logMealFromTemplate(Long userId, LogMealFromTemplateRequest request);

    /**
     * Get daily meal logs
     */
    List<NutritionLogResponse> getDailyLogs(Long userId, LocalDate date);

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

    // ========== Dashboard (UC-7.5) ==========

    /**
     * Get nutrition dashboard with all relevant data
     */
    NutritionDashboardResponse getDashboard(Long userId);

    // ========== Meal Templates (UC-7.6) ==========

    /**
     * Get all system-provided meal templates
     */
    List<MealTemplateResponse> getMealTemplates();

    // ========== Weekly View ==========

    /**
     * Get daily nutrition totals for a date range (weekly calendar view).
     */
    List<DailyNutritionSummaryResponse> getWeeklyTotals(Long userId, LocalDate weekStart, LocalDate weekEnd);

}
