package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateNutritionPlanRequest;
import com.dev.backend.model.dto.request.LogMealRequest;
import com.dev.backend.model.dto.request.ScheduleMealRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.*;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

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

    // ========== Plan Meal (replaces Nutrition Log) ==========

    /**
     * Convert a free-form LogMealRequest into a PlanMeal entity
     * with status=COMPLETED and source=MANUAL.
     */
    public PlanMeal toPlanMealEntity(LogMealRequest request, User user) {
        PlanMeal meal = new PlanMeal();
        meal.setUser(user);
        meal.setScheduledDate(request.getLogDate() != null ? request.getLogDate() : LocalDate.now());
        meal.setMealType(request.getMealType());
        meal.setFoodName(request.getFoodName());
        meal.setCalories(request.getCalories());
        meal.setProteinG(request.getProteinG());
        meal.setCarbsG(request.getCarbsG());
        meal.setFatsG(request.getFatsG());
        meal.setMealTime(request.getMealTime());
        meal.setIsCheatMeal(request.getIsCheatMeal() != null ? request.getIsCheatMeal() : false);
        meal.setNotes(request.getNotes());
        meal.setStatus(PlanMealStatus.COMPLETED);
        meal.setCompletedAt(Instant.now());
        meal.setSource(PlanMealSource.MANUAL);
        return meal;
    }

    /**
     * Convert a ScheduleMealRequest + MealTemplate into a PlanMeal entity
     * with status=PLANNED and source=TEMPLATE.
     */
    public PlanMeal toPlanMealEntity(ScheduleMealRequest request, MealTemplate template,
                                     NutritionPlan plan, User user) {
        PlanMeal meal = new PlanMeal();
        meal.setUser(user);
        meal.setNutritionPlan(plan);
        meal.setMealTemplate(template);
        meal.setScheduledDate(request.getScheduledDate());
        meal.setMealType(request.getMealType());
        meal.setMealTime(request.getMealTime());
        meal.setNotes(request.getNotes());
        meal.setStatus(PlanMealStatus.PLANNED);
        meal.setSource(PlanMealSource.TEMPLATE);
        meal.setIsCheatMeal(false);
        // Copy denormalized data from template
        meal.setFoodName(template.getMealName());
        meal.setCalories(template.getCalories());
        meal.setProteinG(template.getProteinG());
        meal.setCarbsG(template.getCarbsG());
        meal.setFatsG(template.getFatsG());
        return meal;
    }

    /**
     * Create a PlanMeal from a MealTemplate for generated meals (RCM/AI).
     */
    public PlanMeal toPlanMealFromGenerated(MealTemplate template, NutritionPlan plan,
                                            User user, LocalDate date, PlanMealSource source) {
        PlanMeal meal = new PlanMeal();
        meal.setUser(user);
        meal.setNutritionPlan(plan);
        meal.setMealTemplate(template);
        meal.setScheduledDate(date);
        meal.setMealType(template.getMealType() != null ? MealType.valueOf(template.getMealType()) : null);
        meal.setStatus(PlanMealStatus.PLANNED);
        meal.setSource(source);
        meal.setIsCheatMeal(false);
        // Copy denormalized data from template
        meal.setFoodName(template.getMealName());
        meal.setCalories(template.getCalories());
        meal.setProteinG(template.getProteinG());
        meal.setCarbsG(template.getCarbsG());
        meal.setFatsG(template.getFatsG());
        return meal;
    }

    public PlanMealResponse toResponse(PlanMeal entity) {
        PlanMealResponse.PlanMealResponseBuilder builder = PlanMealResponse.builder()
                .planMealId(entity.getPlanMealId())
                .nutritionPlanId(entity.getNutritionPlan() != null
                        ? entity.getNutritionPlan().getNutritionPlanId() : null)
                .mealTemplateId(entity.getMealTemplate() != null
                        ? entity.getMealTemplate().getMealTemplateId() : null)
                .scheduledDate(entity.getScheduledDate())
                .mealType(entity.getMealType())
                .status(entity.getStatus())
                .source(entity.getSource())
                .foodName(entity.getFoodName())
                .calories(entity.getCalories())
                .proteinG(entity.getProteinG())
                .carbsG(entity.getCarbsG())
                .fatsG(entity.getFatsG())
                .mealTime(entity.getMealTime())
                .completedAt(entity.getCompletedAt())
                .isCheatMeal(entity.getIsCheatMeal())
                .notes(entity.getNotes());

        // Include full template details if meal is from a template
        if (entity.getMealTemplate() != null) {
            builder.mealTemplate(toResponse(entity.getMealTemplate()));
        }

        return builder.build();
    }

    // ========== Cheat Meal Log ==========

    public CheatMealLogResponse toResponse(CheatMealLog entity) {
        CheatMealLogResponse.CheatMealLogResponseBuilder builder = CheatMealLogResponse.builder()
                .cheatMealLogId(entity.getCheatMealLogId())
                .cheatDate(entity.getCheatDate())
                .excessCalories(entity.getExcessCalories())
                .compensationStrategy(entity.getCompensationStrategy())
                .isCompensated(entity.getIsCompensated());

        if (entity.getPlanMeal() != null) {
            builder.planMealId(entity.getPlanMeal().getPlanMealId());
            builder.mealName(entity.getPlanMeal().getFoodName());
            builder.mealCalories(entity.getPlanMeal().getCalories());
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
                .source(entity.getSource())
                .description(entity.getDescription())
                .calories(entity.getCalories())
                .proteinG(entity.getProteinG())
                .carbsG(entity.getCarbsG())
                .fatsG(entity.getFatsG())
                .recipeInstructions(entity.getRecipeInstructions())
                .build();
    }

    // ========== Nutrition Day ==========

    public NutritionDayResponse toResponse(NutritionDay entity) {
        List<DayMealResponse> meals = entity.getDayMeals() != null
                ? entity.getDayMeals().stream()
                    .map(this::toResponse)
                    .collect(Collectors.toList())
                : List.of();

        return NutritionDayResponse.builder()
                .nutritionDayId(entity.getNutritionDayId())
                .dayNumber(entity.getDayNumber())
                .dayName(entity.getDayName())
                .description(entity.getDescription())
                .targetCalories(entity.getTargetCalories())
                .isRestDay(entity.getIsRestDay())
                .meals(meals)
                .build();
    }

    // ========== Day Meal ==========

    public DayMealResponse toResponse(DayMeal entity) {
        MealTemplate t = entity.getMealTemplate();

        // Use custom overrides if set, otherwise fall back to template values
        Integer calories = entity.getCustomCalories() != null ? entity.getCustomCalories() : t.getCalories();
        Float proteinG = entity.getCustomProteinG() != null ? entity.getCustomProteinG() : t.getProteinG();
        Float carbsG = entity.getCustomCarbsG() != null ? entity.getCustomCarbsG() : t.getCarbsG();
        Float fatsG = entity.getCustomFatsG() != null ? entity.getCustomFatsG() : t.getFatsG();

        return DayMealResponse.builder()
                .dayMealId(entity.getDayMealId())
                .mealType(entity.getMealType())
                .orderIndex(entity.getOrderIndex())
                .calories(calories)
                .proteinG(proteinG)
                .carbsG(carbsG)
                .fatsG(fatsG)
                .notes(entity.getNotes())
                .completedAt(entity.getCompletedAt())
                .mealTemplate(toResponse(t))
                .build();
    }
}

