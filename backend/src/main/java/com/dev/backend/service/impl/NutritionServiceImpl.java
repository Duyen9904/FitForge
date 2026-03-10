package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.NutritionMapper;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.model.enums.PlanMealStatus;
import com.dev.backend.repository.*;
import com.dev.backend.service.NutritionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NutritionServiceImpl implements NutritionService {

    private final NutritionPlanRepository planRepository;
    private final PlanMealRepository planMealRepository;
    private final CheatMealLogRepository cheatMealLogRepository;
    private final MealTemplateRepository templateRepository;
    private final CompensationActionRepository compensationRepository;
    private final NutritionDayRepository nutritionDayRepository;
    private final DayMealRepository dayMealRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final NutritionMapper mapper;

    public NutritionServiceImpl(
            NutritionPlanRepository planRepository,
            PlanMealRepository planMealRepository,
            CheatMealLogRepository cheatMealLogRepository,
            MealTemplateRepository templateRepository,
            CompensationActionRepository compensationRepository,
            NutritionDayRepository nutritionDayRepository,
            DayMealRepository dayMealRepository,
            UserRepository userRepository,
            GoalRepository goalRepository,
            NutritionMapper mapper) {
        this.planRepository = planRepository;
        this.planMealRepository = planMealRepository;
        this.cheatMealLogRepository = cheatMealLogRepository;
        this.templateRepository = templateRepository;
        this.compensationRepository = compensationRepository;
        this.nutritionDayRepository = nutritionDayRepository;
        this.dayMealRepository = dayMealRepository;
        this.userRepository = userRepository;
        this.goalRepository = goalRepository;
        this.mapper = mapper;
    }

    // ========== Nutrition Plan (UC-7.1) ==========

    @Override
    public NutritionPlanResponse createNutritionPlan(Long userId, CreateNutritionPlanRequest request) {
        User user = findUserOrThrow(userId);

        // Check if user already has a plan
        if (planRepository.existsByUserUserId(userId)) {
            throw new IllegalStateException("User already has a nutrition plan. Use update instead.");
        }

        Goal goal = null;
        if (request.getGoalId() != null) {
            goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal not found"));
        }

        NutritionPlan plan = mapper.toEntity(request, user, goal);
        plan = planRepository.save(plan);
        return mapper.toResponse(plan);
    }

    @Override
    public NutritionPlanResponse updateNutritionPlan(Long userId, Long planId, UpdateNutritionPlanRequest request) {
        NutritionPlan plan = planRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found"));

        if (request.getPlanName() != null) plan.setPlanName(request.getPlanName());
        if (request.getDailyCalorieTarget() != null) plan.setDailyCalorieTarget(request.getDailyCalorieTarget());
        if (request.getProteinPercentage() != null) plan.setProteinPercentage(request.getProteinPercentage());
        if (request.getCarbsPercentage() != null) plan.setCarbsPercentage(request.getCarbsPercentage());
        if (request.getFatsPercentage() != null) plan.setFatsPercentage(request.getFatsPercentage());
        if (request.getCheatMealsPerWeek() != null) plan.setCheatMealsPerWeek(request.getCheatMealsPerWeek());
        if (request.getAutoAdjustEnabled() != null) plan.setAutoAdjustEnabled(request.getAutoAdjustEnabled());

        if (request.getGoalId() != null) {
            Goal goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal not found"));
            plan.setGoal(goal);
        }

        plan = planRepository.save(plan);
        return mapper.toResponse(plan);
    }

    @Override
    @Transactional(readOnly = true)
    public NutritionPlanResponse getActivePlan(Long userId) {
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(userId)
                .orElseThrow(() -> new ResourceNotFoundException("No active nutrition plan found"));
        return mapper.toResponse(plan);
    }

    @Override
    @Transactional
    public void deletePlan(Long userId, Long planId) {
        NutritionPlan plan = planRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found: " + planId));
        planRepository.delete(plan);
    }

    @Override
    @Transactional
    public NutritionPlanResponse deactivatePlan(Long userId, Long planId) {
        NutritionPlan plan = planRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found: " + planId));
        plan.setIsActive(false);
        plan = planRepository.save(plan);
        return mapper.toResponse(plan);
    }

    // ========== Meal Logging (UC-7.2, UC-7.3) ==========

    @Override
    public PlanMealResponse logMeal(Long userId, LogMealRequest request) {
        User user = findUserOrThrow(userId);

        PlanMeal meal;
        if (request.getTemplateId() != null) {
            // Template-based log
            MealTemplate template = templateRepository.findById(request.getTemplateId())
                    .orElseThrow(() -> new ResourceNotFoundException("Meal template not found"));

            float multiplier = request.getQuantityMultiplier() != null ? request.getQuantityMultiplier() : 1.0f;

            meal = new PlanMeal();
            meal.setUser(user);
            meal.setMealTemplate(template);
            meal.setScheduledDate(request.getLogDate() != null ? request.getLogDate() : LocalDate.now());
            meal.setMealType(request.getMealType() != null ? request.getMealType()
                    : (template.getMealType() != null ? com.dev.backend.model.enums.MealType.valueOf(template.getMealType()) : null));
            meal.setFoodName(template.getMealName());
            meal.setCalories(template.getCalories() != null ? Math.round(template.getCalories() * multiplier) : null);
            meal.setProteinG(template.getProteinG() != null ? template.getProteinG() * multiplier : null);
            meal.setCarbsG(template.getCarbsG() != null ? template.getCarbsG() * multiplier : null);
            meal.setFatsG(template.getFatsG() != null ? template.getFatsG() * multiplier : null);
            meal.setMealTime(request.getMealTime());
            meal.setIsCheatMeal(request.getIsCheatMeal() != null ? request.getIsCheatMeal() : false);
            meal.setNotes(request.getNotes());
            meal.setStatus(PlanMealStatus.COMPLETED);
            meal.setCompletedAt(Instant.now());
            meal.setSource(com.dev.backend.model.enums.PlanMealSource.TEMPLATE);
        } else {
            // Manual free-form log
            meal = mapper.toPlanMealEntity(request, user);
        }

        // If replaceExisting is true, delete existing meals of the same type on the same date
        if (Boolean.TRUE.equals(request.getReplaceExisting())) {
            com.dev.backend.model.enums.MealType resolvedType = meal.getMealType();
            LocalDate resolvedDate = meal.getScheduledDate();
            if (resolvedType != null && resolvedDate != null) {
                List<PlanMeal> existing = planMealRepository
                        .findByUserUserIdAndScheduledDateAndMealTypeAndStatusNot(
                                userId, resolvedDate, resolvedType, PlanMealStatus.SKIPPED);
                if (!existing.isEmpty()) {
                    planMealRepository.deleteAll(existing);
                }
            }
        }

        meal = planMealRepository.save(meal);

        // Create cheat meal log if flagged
        if (Boolean.TRUE.equals(meal.getIsCheatMeal())) {
            createCheatMealLog(user, meal);
        }

        return mapper.toResponse(meal);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PlanMealResponse> getDailyMeals(Long userId, LocalDate date) {
        LocalDate logDate = date != null ? date : LocalDate.now();
        return planMealRepository.findByUserUserIdAndScheduledDateAndStatusNotOrderByMealTimeAsc(
                userId, logDate, PlanMealStatus.SKIPPED)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public DailyNutritionSummaryResponse getDailySummary(Long userId, LocalDate date) {
        LocalDate logDate = date != null ? date : LocalDate.now();

        // Get totals from completed PlanMeal records
        com.dev.backend.model.projection.DailyNutritionAggregate planAggregate =
                planMealRepository.getDailySummary(userId, logDate);

        int totalCalories = 0;
        float totalProtein = 0;
        float totalCarbs = 0;
        float totalFats = 0;

        if (planAggregate != null) {
            if (planAggregate.getTotalCalories() != null) {
                totalCalories += planAggregate.getTotalCalories().intValue();
            }
            if (planAggregate.getTotalProtein() != null) {
                totalProtein += planAggregate.getTotalProtein().floatValue();
            }
            if (planAggregate.getTotalCarbs() != null) {
                totalCarbs += planAggregate.getTotalCarbs().floatValue();
            }
            if (planAggregate.getTotalFats() != null) {
                totalFats += planAggregate.getTotalFats().floatValue();
            }
        }

        // Also include completed DayMeal records (meals completed from the plan day view)
        Instant dayStart = logDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
        Instant dayEnd = logDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
        com.dev.backend.model.projection.DailyNutritionAggregate dayMealAggregate =
                dayMealRepository.getCompletedDayMealSummary(userId, dayStart, dayEnd);

        if (dayMealAggregate != null) {
            if (dayMealAggregate.getTotalCalories() != null) {
                totalCalories += dayMealAggregate.getTotalCalories().intValue();
            }
            if (dayMealAggregate.getTotalProtein() != null) {
                totalProtein += dayMealAggregate.getTotalProtein().floatValue();
            }
            if (dayMealAggregate.getTotalCarbs() != null) {
                totalCarbs += dayMealAggregate.getTotalCarbs().floatValue();
            }
            if (dayMealAggregate.getTotalFats() != null) {
                totalFats += dayMealAggregate.getTotalFats().floatValue();
            }
        }

        // Get targets from plan
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(userId).orElse(null);
        
        DailyNutritionSummaryResponse.DailyNutritionSummaryResponseBuilder builder = 
                DailyNutritionSummaryResponse.builder()
                .date(logDate)
                .totalCalories(totalCalories)
                .totalProteinG(totalProtein)
                .totalCarbsG(totalCarbs)
                .totalFatsG(totalFats);

        if (plan != null && plan.getDailyCalorieTarget() != null) {
            int targetCal = plan.getDailyCalorieTarget();
            float targetProtein = (targetCal * plan.getProteinPercentage() / 100) / 4;
            float targetCarbs = (targetCal * plan.getCarbsPercentage() / 100) / 4;
            float targetFats = (targetCal * plan.getFatsPercentage() / 100) / 9;

            builder.targetCalories(targetCal)
                    .targetProteinG(targetProtein)
                    .targetCarbsG(targetCarbs)
                    .targetFatsG(targetFats)
                    .remainingCalories(targetCal - totalCalories)
                    .remainingProteinG(targetProtein - totalProtein)
                    .remainingCarbsG(targetCarbs - totalCarbs)
                    .remainingFatsG(targetFats - totalFats)
                    .calorieProgress(targetCal > 0 ? (totalCalories * 100f / targetCal) : 0)
                    .proteinProgress(targetProtein > 0 ? (totalProtein * 100f / targetProtein) : 0)
                    .carbsProgress(targetCarbs > 0 ? (totalCarbs * 100f / targetCarbs) : 0)
                    .fatsProgress(targetFats > 0 ? (totalFats * 100f / targetFats) : 0);
        }

        // Count cheat meals for the day
        long cheatCount = planMealRepository.countByUserUserIdAndScheduledDateAndIsCheatMealTrueAndStatus(
                userId, logDate, PlanMealStatus.COMPLETED);
        builder.cheatMealCount((int) cheatCount);

        return builder.build();
    }

    // ========== Cheat Meal Management (UC-7.3, UC-7.4) ==========

    private void createCheatMealLog(User user, PlanMeal mealLog) {
        // Get plan to calculate excess calories
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(user.getUserId()).orElse(null);
        
        int excessCalories = 0;
        if (plan != null && plan.getDailyCalorieTarget() != null) {
            // Assume average meal is 1/3 of daily target
            int avgMealCalories = plan.getDailyCalorieTarget() / 3;
            excessCalories = Math.max(0, mealLog.getCalories() - avgMealCalories);
        } else {
            // Default: consider anything over 800 calories as excess
            excessCalories = Math.max(0, mealLog.getCalories() - 800);
        }

        CheatMealLog cheatLog = new CheatMealLog();
        cheatLog.setPlanMeal(mealLog);
        cheatLog.setUser(user);
        cheatLog.setCheatDate(mealLog.getScheduledDate());
        cheatLog.setExcessCalories(excessCalories);
        cheatLog.setIsCompensated(false);

        cheatMealLogRepository.save(cheatLog);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CheatMealLogResponse> getUncompensatedCheatMeals(Long userId) {
        return cheatMealLogRepository.findByUserUserIdAndIsCompensatedFalse(userId)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<CompensationActionResponse> generateCompensationOptions(Long userId, Long cheatMealLogId) {
        CheatMealLog cheatLog = cheatMealLogRepository.findById(cheatMealLogId)
                .filter(c -> c.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Cheat meal log not found"));

        int excessCalories = cheatLog.getExcessCalories() != null ? cheatLog.getExcessCalories() : 0;
        List<CompensationActionResponse> options = new ArrayList<>();

        // Option A: Add cardio
        int cardioMinutes = (int) Math.ceil(excessCalories / 10.0); // ~10 cal/min for moderate cardio
        options.add(CompensationActionResponse.builder()
                .compensationType(CompensationType.ADD_CARDIO)
                .actionType("ADD_CARDIO")
                .actionDescription(String.format("Add %d minutes of cardio to your next 2 workouts", cardioMinutes / 2))
                .calorieAdjustment(-excessCalories)
                .details(String.format("Burns approximately %d calories total", excessCalories))
                .build());

        // Option B: Reduce calories
        int daysToReduce = (int) Math.ceil(excessCalories / 200.0);
        int dailyReduction = excessCalories / daysToReduce;
        options.add(CompensationActionResponse.builder()
                .compensationType(CompensationType.REDUCE_CALORIES)
                .actionType("REDUCE_CALORIES")
                .actionDescription(String.format("Reduce daily calories by %d for the next %d days", dailyReduction, daysToReduce))
                .calorieAdjustment(-dailyReduction)
                .details(String.format("Total deficit: %d calories over %d days", excessCalories, daysToReduce))
                .build());

        // Option C: Combination
        int comboCardio = cardioMinutes / 2;
        int comboDays = Math.max(1, daysToReduce / 2);
        int comboReduction = (excessCalories / 2) / comboDays;
        options.add(CompensationActionResponse.builder()
                .compensationType(CompensationType.COMBINATION)
                .actionType("COMBINATION")
                .actionDescription(String.format("Add %d min cardio + reduce %d cal/day for %d days", 
                        comboCardio, comboReduction, comboDays))
                .calorieAdjustment(-excessCalories)
                .details("Balanced approach combining exercise and calorie reduction")
                .build());

        // Option D: Do nothing
        options.add(CompensationActionResponse.builder()
                .compensationType(CompensationType.DO_NOTHING)
                .actionType("DO_NOTHING")
                .actionDescription("Accept the deviation and continue with normal plan")
                .calorieAdjustment(0)
                .details("No compensation needed - one cheat meal won't derail your progress")
                .build());

        return options;
    }

    @Override
    public CompensationActionResponse selectCompensation(Long userId, Long cheatMealLogId, SelectCompensationRequest request) {
        CheatMealLog cheatLog = cheatMealLogRepository.findById(cheatMealLogId)
                .filter(c -> c.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Cheat meal log not found"));

        // Generate the selected option details
        List<CompensationActionResponse> options = generateCompensationOptions(userId, cheatMealLogId);
        CompensationActionResponse selectedOption = options.stream()
                .filter(o -> o.getCompensationType() == request.getCompensationType())
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Invalid compensation type"));

        // Create compensation action if not "do nothing"
        if (request.getCompensationType() != CompensationType.DO_NOTHING) {
            CompensationAction action = new CompensationAction();
            action.setCheatMealLog(cheatLog);
            action.setActionType(request.getCompensationType().name());
            action.setActionDescription(selectedOption.getActionDescription());
            action.setScheduledDate(LocalDate.now().plusDays(1));
            action.setCalorieAdjustment(selectedOption.getCalorieAdjustment());
            action.setDetails(selectedOption.getDetails());
            action.setIsCompleted(false);

            action = compensationRepository.save(action);
            selectedOption = mapper.toResponse(action);
        }

        // Update cheat log
        cheatLog.setCompensationStrategy(request.getCompensationType().name());
        cheatLog.setIsCompensated(request.getCompensationType() == CompensationType.DO_NOTHING);
        cheatMealLogRepository.save(cheatLog);

        return selectedOption;
    }

    // ========== Nutrition Days ==========

    @Override
    @Transactional(readOnly = true)
    public List<NutritionDayResponse> getPlanDays(Long userId, Long planId) {
        NutritionPlan plan = planRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found"));

        List<NutritionDay> days = nutritionDayRepository.findByPlanIdWithMeals(planId);
        return days.stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public NutritionDayResponse getPlanDay(Long userId, Long planId, int dayNumber) {
        NutritionPlan plan = planRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found"));

        NutritionDay day = nutritionDayRepository.findByPlanIdAndDayNumberWithMeals(planId, dayNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Nutrition day not found"));

        return mapper.toResponse(day);
    }

    // ========== Meal Templates (UC-7.6) ==========

    @Override
    @Transactional(readOnly = true)
    public List<MealTemplateResponse> getMealTemplates() {
        return templateRepository.findAll()
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public MealTemplateResponse getMealTemplateById(Long templateId) {
        MealTemplate template = templateRepository.findById(templateId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal template not found"));
        return mapper.toResponse(template);
    }

    // ========== Weekly View ==========

    @Override
    @Transactional(readOnly = true)
    public List<DailyNutritionSummaryResponse> getWeeklyTotals(Long userId, LocalDate weekStart, LocalDate weekEnd) {
        List<DailyNutritionSummaryResponse> result = new ArrayList<>();
        LocalDate current = weekStart;
        while (!current.isAfter(weekEnd)) {
            result.add(getDailySummary(userId, current));
            current = current.plusDays(1);
        }
        return result;
    }

    // ========== Plan Meals ==========

    @Override
    public PlanMealResponse scheduleMeal(Long userId, ScheduleMealRequest request) {
        User user = findUserOrThrow(userId);

        // Use provided planId, or fall back to active plan
        NutritionPlan plan;
        if (request.getPlanId() != null) {
            plan = planRepository.findById(request.getPlanId())
                    .filter(p -> p.getUser().getUserId().equals(userId))
                    .orElseThrow(() -> new ResourceNotFoundException("Nutrition plan not found"));
        } else {
            plan = planRepository.findByUserUserIdAndIsActiveTrue(userId)
                    .orElseThrow(() -> new ResourceNotFoundException("No active nutrition plan found"));
        }

        MealTemplate template = templateRepository.findById(request.getTemplateId())
                .orElseThrow(() -> new ResourceNotFoundException("Meal template not found"));

        PlanMeal meal = mapper.toPlanMealEntity(request, template, plan, user);
        meal = planMealRepository.save(meal);
        return mapper.toResponse(meal);
    }

    @Override
    public PlanMealResponse completePlanMeal(Long userId, Long planMealId) {
        PlanMeal meal = planMealRepository.findById(planMealId)
                .filter(m -> m.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Plan meal not found"));

        meal.setStatus(PlanMealStatus.COMPLETED);
        meal.setCompletedAt(Instant.now());
        meal = planMealRepository.save(meal);
        return mapper.toResponse(meal);
    }

    @Override
    public PlanMealResponse skipPlanMeal(Long userId, Long planMealId) {
        PlanMeal meal = planMealRepository.findById(planMealId)
                .filter(m -> m.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Plan meal not found"));

        meal.setStatus(PlanMealStatus.SKIPPED);
        meal = planMealRepository.save(meal);
        return mapper.toResponse(meal);
    }

    // ========== Day Meals ==========

    @Override
    public DayMealResponse completeDayMeal(Long userId, Long dayMealId) {
        DayMeal dayMeal = dayMealRepository.findById(dayMealId)
                .orElseThrow(() -> new ResourceNotFoundException("Day meal not found"));

        // Verify ownership: dayMeal → nutritionDay → nutritionPlan → user
        Long planOwnerId = dayMeal.getNutritionDay()
                .getNutritionPlan()
                .getUser()
                .getUserId();
        if (!planOwnerId.equals(userId)) {
            throw new ResourceNotFoundException("Day meal not found");
        }

        dayMeal.setCompletedAt(Instant.now());
        dayMeal = dayMealRepository.save(dayMeal);
        return mapper.toResponse(dayMeal);
    }

    // ========== Helper Methods ==========

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
