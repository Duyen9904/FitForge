package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateNutritionPlanRequest;
import com.dev.backend.model.dto.request.LogMealRequest;
import com.dev.backend.model.dto.request.ScheduleMealRequest;
import com.dev.backend.model.dto.response.CheatMealLogResponse;
import com.dev.backend.model.dto.response.CompensationActionResponse;
import com.dev.backend.model.dto.response.DayMealResponse;
import com.dev.backend.model.dto.response.MealTemplateResponse;
import com.dev.backend.model.dto.response.NutritionDayResponse;
import com.dev.backend.model.dto.response.NutritionPlanResponse;
import com.dev.backend.model.dto.response.PlanMealResponse;
import com.dev.backend.model.entity.CheatMealLog;
import com.dev.backend.model.entity.CompensationAction;
import com.dev.backend.model.entity.DayMeal;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionDay;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.model.entity.PlanMeal;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.model.enums.MealType;
import com.dev.backend.model.enums.PlanMealSource;
import com.dev.backend.model.enums.PlanMealStatus;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface NutritionMapper extends BaseMapper<NutritionPlan, CreateNutritionPlanRequest, NutritionPlanResponse> {

    // ========== Nutrition Plan ==========

    @Override
    @Mapping(target = "cheatMealsPerWeek", expression = "java(request.getCheatMealsPerWeek() != null ? request.getCheatMealsPerWeek() : 0)")
    @Mapping(target = "autoAdjustEnabled", expression = "java(request.getAutoAdjustEnabled() != null ? request.getAutoAdjustEnabled() : false)")
    @Mapping(target = "isActive", constant = "true")
    NutritionPlan toEntity(CreateNutritionPlanRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget NutritionPlan entity, CreateNutritionPlanRequest request);

    @Mapping(target = "user", source = "user")
    @Mapping(target = "goal", source = "goal")
    @Mapping(target = "planName", source = "request.planName")
    @Mapping(target = "dailyCalorieTarget", source = "request.dailyCalorieTarget")
    @Mapping(target = "proteinPercentage", source = "request.proteinPercentage")
    @Mapping(target = "carbsPercentage", source = "request.carbsPercentage")
    @Mapping(target = "fatsPercentage", source = "request.fatsPercentage")
    @Mapping(target = "cheatMealsPerWeek", expression = "java(request.getCheatMealsPerWeek() != null ? request.getCheatMealsPerWeek() : 0)")
    @Mapping(target = "autoAdjustEnabled", expression = "java(request.getAutoAdjustEnabled() != null ? request.getAutoAdjustEnabled() : false)")
    @Mapping(target = "isActive", constant = "true")
    NutritionPlan toEntity(CreateNutritionPlanRequest request, User user, Goal goal);

    @Override
    @Mapping(target = "goalId", source = "goal.goalId")
    @Mapping(target = "goalName", source = "goal.goalName")
    @Mapping(target = "proteinGrams", expression = "java(calculateMacroGrams(entity.getDailyCalorieTarget(), entity.getProteinPercentage(), 4))")
    @Mapping(target = "carbsGrams", expression = "java(calculateMacroGrams(entity.getDailyCalorieTarget(), entity.getCarbsPercentage(), 4))")
    @Mapping(target = "fatsGrams", expression = "java(calculateMacroGrams(entity.getDailyCalorieTarget(), entity.getFatsPercentage(), 9))")
    NutritionPlanResponse toResponse(NutritionPlan entity);

    default Float calculateMacroGrams(Integer calories, Float percentage, int calPerGram) {
        if (calories == null || percentage == null) {
            return null;
        }
        return (calories * percentage / 100) / calPerGram;
    }

    // ========== Plan Meal (replaces Nutrition Log) ==========

    @Mapping(target = "user", source = "user")
    @Mapping(target = "scheduledDate", expression = "java(request.getLogDate() != null ? request.getLogDate() : java.time.LocalDate.now())")
    @Mapping(target = "mealType", source = "request.mealType")
    @Mapping(target = "foodName", source = "request.foodName")
    @Mapping(target = "calories", source = "request.calories")
    @Mapping(target = "proteinG", source = "request.proteinG")
    @Mapping(target = "carbsG", source = "request.carbsG")
    @Mapping(target = "fatsG", source = "request.fatsG")
    @Mapping(target = "mealTime", source = "request.mealTime")
    @Mapping(target = "isCheatMeal", expression = "java(request.getIsCheatMeal() != null ? request.getIsCheatMeal() : false)")
    @Mapping(target = "notes", source = "request.notes")
    @Mapping(target = "status", expression = "java(com.dev.backend.model.enums.PlanMealStatus.COMPLETED)")
    @Mapping(target = "completedAt", expression = "java(java.time.Instant.now())")
    @Mapping(target = "source", expression = "java(com.dev.backend.model.enums.PlanMealSource.MANUAL)")
    PlanMeal toPlanMealEntity(LogMealRequest request, User user);

    @Mapping(target = "user", source = "user")
    @Mapping(target = "nutritionPlan", source = "plan")
    @Mapping(target = "mealTemplate", source = "template")
    @Mapping(target = "scheduledDate", source = "request.scheduledDate")
    @Mapping(target = "mealType", source = "request.mealType")
    @Mapping(target = "mealTime", source = "request.mealTime")
    @Mapping(target = "notes", source = "request.notes")
    @Mapping(target = "status", expression = "java(com.dev.backend.model.enums.PlanMealStatus.PLANNED)")
    @Mapping(target = "source", expression = "java(com.dev.backend.model.enums.PlanMealSource.TEMPLATE)")
    @Mapping(target = "isCheatMeal", constant = "false")
    @Mapping(target = "foodName", source = "template.mealName")
    @Mapping(target = "calories", source = "template.calories")
    @Mapping(target = "proteinG", source = "template.proteinG")
    @Mapping(target = "carbsG", source = "template.carbsG")
    @Mapping(target = "fatsG", source = "template.fatsG")
    @Mapping(target = "completedAt", ignore = true)
    PlanMeal toPlanMealEntity(ScheduleMealRequest request, MealTemplate template,
                              NutritionPlan plan, User user);

    @Mapping(target = "user", source = "user")
    @Mapping(target = "nutritionPlan", source = "plan")
    @Mapping(target = "mealTemplate", source = "template")
    @Mapping(target = "scheduledDate", source = "date")
    @Mapping(target = "mealType", expression = "java(template.getMealType() != null ? com.dev.backend.model.enums.MealType.valueOf(template.getMealType()) : null)")
    @Mapping(target = "status", expression = "java(com.dev.backend.model.enums.PlanMealStatus.PLANNED)")
    @Mapping(target = "source", source = "source")
    @Mapping(target = "isCheatMeal", constant = "false")
    @Mapping(target = "foodName", source = "template.mealName")
    @Mapping(target = "calories", source = "template.calories")
    @Mapping(target = "proteinG", source = "template.proteinG")
    @Mapping(target = "carbsG", source = "template.carbsG")
    @Mapping(target = "fatsG", source = "template.fatsG")
    @Mapping(target = "mealTime", ignore = true)
    @Mapping(target = "completedAt", ignore = true)
    @Mapping(target = "notes", ignore = true)
    PlanMeal toPlanMealFromGenerated(MealTemplate template, NutritionPlan plan,
                                     User user, LocalDate date, PlanMealSource source);

    @Mapping(target = "nutritionPlanId", source = "nutritionPlan.nutritionPlanId")
    @Mapping(target = "mealTemplateId", source = "mealTemplate.mealTemplateId")
    @Mapping(target = "mealTemplate", source = "mealTemplate")
    PlanMealResponse toResponse(PlanMeal entity);

    // ========== Cheat Meal Log ==========

    @Mapping(target = "planMealId", source = "planMeal.planMealId")
    @Mapping(target = "mealName", source = "planMeal.foodName")
    @Mapping(target = "mealCalories", source = "planMeal.calories")
    CheatMealLogResponse toResponse(CheatMealLog entity);

    // ========== Compensation Action ==========

    @Mapping(target = "compensationType", expression = "java(parseCompensationType(entity.getActionType()))")
    @Mapping(target = "daysRemaining", expression = "java(calculateDaysRemaining(entity.getScheduledDate()))")
    @Mapping(target = "progressStatus", expression = "java(calculateProgressStatus(entity.getScheduledDate(), entity.getIsCompleted()))")
    CompensationActionResponse toResponse(CompensationAction entity);

    default CompensationType parseCompensationType(String actionType) {
        if (actionType == null) {
            return null;
        }
        try {
            return CompensationType.valueOf(actionType);
        } catch (Exception e) {
            return null;
        }
    }

    default Integer calculateDaysRemaining(LocalDate scheduledDate) {
        if (scheduledDate == null) {
            return null;
        }
        long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), scheduledDate);
        return (int) Math.max(0, daysRemaining);
    }

    default String calculateProgressStatus(LocalDate scheduledDate, Boolean isCompleted) {
        if (scheduledDate == null) {
            return null;
        }
        long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), scheduledDate);
        return Boolean.TRUE.equals(isCompleted) ? "completed" : daysRemaining < 0 ? "overdue" : "pending";
    }

    // ========== Meal Template ==========

    @Mapping(target = "mealType", expression = "java(entity.getMealType() != null ? com.dev.backend.model.enums.MealType.valueOf(entity.getMealType()) : null)")
    MealTemplateResponse toResponse(MealTemplate entity);

    // ========== Nutrition Day ==========

    @Mapping(target = "meals", expression = "java(entity.getDayMeals() != null ? toDayMealResponseList(entity.getDayMeals()) : java.util.List.of())")
    NutritionDayResponse toResponse(NutritionDay entity);

    List<DayMealResponse> toDayMealResponseList(List<DayMeal> entities);

    // ========== Day Meal ==========

    @Mapping(target = "calories", expression = "java(entity.getCustomCalories() != null ? entity.getCustomCalories() : (entity.getMealTemplate() != null ? entity.getMealTemplate().getCalories() : null))")
    @Mapping(target = "proteinG", expression = "java(entity.getCustomProteinG() != null ? entity.getCustomProteinG() : (entity.getMealTemplate() != null ? entity.getMealTemplate().getProteinG() : null))")
    @Mapping(target = "carbsG", expression = "java(entity.getCustomCarbsG() != null ? entity.getCustomCarbsG() : (entity.getMealTemplate() != null ? entity.getMealTemplate().getCarbsG() : null))")
    @Mapping(target = "fatsG", expression = "java(entity.getCustomFatsG() != null ? entity.getCustomFatsG() : (entity.getMealTemplate() != null ? entity.getMealTemplate().getFatsG() : null))")
    @Mapping(target = "mealTemplate", source = "mealTemplate")
    DayMealResponse toResponse(DayMeal entity);
}
