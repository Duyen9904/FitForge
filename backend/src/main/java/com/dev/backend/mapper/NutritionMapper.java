package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateNutritionPlanRequest;
import com.dev.backend.model.dto.request.LogMealRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.model.enums.MealType;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Component
public class NutritionMapper {

    // ========== Nutrition Plan ==========

    public NutritionPlan toEntity(CreateNutritionPlanRequest request, User user, Goal goal) {
        NutritionPlan plan = new NutritionPlan();
        plan.setUser(user);
        plan.setGoal(goal);
        plan.setPlanName(request.getPlanName());
        plan.setDailyCalorieTarget(request.getDailyCalorieTarget());
        plan.setProteinPercentage(request.getProteinPercentage());
        plan.setCarbsPercentage(request.getCarbsPercentage());
        plan.setFatsPercentage(request.getFatsPercentage());
        plan.setCheatMealsPerWeek(request.getCheatMealsPerWeek() != null ? request.getCheatMealsPerWeek() : 0);
        plan.setAutoAdjustEnabled(request.getAutoAdjustEnabled() != null ? request.getAutoAdjustEnabled() : false);
        plan.setIsActive(true);
        return plan;
    }

    public NutritionPlanResponse toResponse(NutritionPlan entity) {
        NutritionPlanResponse.NutritionPlanResponseBuilder builder = NutritionPlanResponse.builder()
                .nutritionPlanId(entity.getNutritionPlanId())
                .planName(entity.getPlanName())
                .dailyCalorieTarget(entity.getDailyCalorieTarget())
                .algorithmVersion(entity.getAlgorithmVersion())
                .version(entity.getVersion())
                .recommendationReason(entity.getRecommendationReason())
                .proteinPercentage(entity.getProteinPercentage())
                .carbsPercentage(entity.getCarbsPercentage())
                .fatsPercentage(entity.getFatsPercentage())
                .cheatMealsPerWeek(entity.getCheatMealsPerWeek())
                .autoAdjustEnabled(entity.getAutoAdjustEnabled())
                .isActive(entity.getIsActive());

        if (entity.getGoal() != null) {
            builder.goalId(entity.getGoal().getGoalId());
            builder.goalName(entity.getGoal().getGoalName());
        }

        // Calculate macro grams from percentages
        // Protein: 4 cal/g, Carbs: 4 cal/g, Fats: 9 cal/g
        if (entity.getDailyCalorieTarget() != null) {
            int calories = entity.getDailyCalorieTarget();
            if (entity.getProteinPercentage() != null) {
                builder.proteinGrams((calories * entity.getProteinPercentage() / 100) / 4);
            }
            if (entity.getCarbsPercentage() != null) {
                builder.carbsGrams((calories * entity.getCarbsPercentage() / 100) / 4);
            }
            if (entity.getFatsPercentage() != null) {
                builder.fatsGrams((calories * entity.getFatsPercentage() / 100) / 9);
            }
        }


        return builder.build();
    }

    // ========== Nutrition Log ==========

    public NutritionLog toEntity(LogMealRequest request, User user) {
        NutritionLog log = new NutritionLog();
        log.setUser(user);
        log.setLogDate(request.getLogDate() != null ? request.getLogDate() : LocalDate.now());
        log.setMealType(request.getMealType() != null ? request.getMealType().name() : null);
        log.setFoodName(request.getFoodName());
        log.setCalories(request.getCalories());
        log.setProteinG(request.getProteinG());
        log.setCarbsG(request.getCarbsG());
        log.setFatsG(request.getFatsG());
        log.setMealTime(request.getMealTime());
        log.setIsCheatMeal(request.getIsCheatMeal() != null ? request.getIsCheatMeal() : false);
        log.setNotes(request.getNotes());
        return log;
    }

    public NutritionLogResponse toResponse(NutritionLog entity) {
        return NutritionLogResponse.builder()
                .nutritionId(entity.getNutritionId())
                .logDate(entity.getLogDate())
                .mealType(entity.getMealType() != null ? MealType.valueOf(entity.getMealType()) : null)
                .foodName(entity.getFoodName())
                .calories(entity.getCalories())
                .proteinG(entity.getProteinG())
                .carbsG(entity.getCarbsG())
                .fatsG(entity.getFatsG())
                .mealTime(entity.getMealTime())
                .isCheatMeal(entity.getIsCheatMeal())
                .notes(entity.getNotes())
                .build();
    }

    // ========== Cheat Meal Log ==========

    public CheatMealLogResponse toResponse(CheatMealLog entity) {
        CheatMealLogResponse.CheatMealLogResponseBuilder builder = CheatMealLogResponse.builder()
                .cheatMealLogId(entity.getCheatMealLogId())
                .cheatDate(entity.getCheatDate())
                .excessCalories(entity.getExcessCalories())
                .compensationStrategy(entity.getCompensationStrategy())
                .isCompensated(entity.getIsCompensated());

        if (entity.getNutritionLog() != null) {
            builder.nutritionLogId(entity.getNutritionLog().getNutritionId());
            builder.mealName(entity.getNutritionLog().getFoodName());
            builder.mealCalories(entity.getNutritionLog().getCalories());
        }

        return builder.build();
    }

    // ========== Compensation Action ==========

    public CompensationActionResponse toResponse(CompensationAction entity) {
        CompensationActionResponse.CompensationActionResponseBuilder builder = CompensationActionResponse.builder()
                .compensationId(entity.getCompensationId())
                .actionType(entity.getActionType())
                .actionDescription(entity.getActionDescription())
                .scheduledDate(entity.getScheduledDate())
                .isCompleted(entity.getIsCompleted())
                .calorieAdjustment(entity.getCalorieAdjustment())
                .details(entity.getDetails());

        // Try to parse compensation type
        try {
            builder.compensationType(CompensationType.valueOf(entity.getActionType()));
        } catch (Exception e) {
            // Ignore if not a valid enum
        }

        // Calculate days remaining
        if (entity.getScheduledDate() != null) {
            long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), entity.getScheduledDate());
            builder.daysRemaining((int) Math.max(0, daysRemaining));
            builder.progressStatus(entity.getIsCompleted() ? "completed" : 
                    daysRemaining < 0 ? "overdue" : "pending");
        }

        return builder.build();
    }

    // ========== Meal Template ==========


    public MealTemplateResponse toResponse(MealTemplate entity) {
        return MealTemplateResponse.builder()
                .mealTemplateId(entity.getMealTemplateId())
                .mealName(entity.getMealName())
                .mealType(entity.getMealType() != null ? MealType.valueOf(entity.getMealType()) : null)
                .description(entity.getDescription())
                .calories(entity.getCalories())
                .proteinG(entity.getProteinG())
                .carbsG(entity.getCarbsG())
                .fatsG(entity.getFatsG())
                .recipeInstructions(entity.getRecipeInstructions())
                .build();
    }
}
