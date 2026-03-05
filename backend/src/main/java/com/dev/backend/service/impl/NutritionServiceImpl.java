package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.NutritionMapper;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.dto.response.NutritionDashboardResponse.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.repository.*;
import com.dev.backend.service.NutritionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NutritionServiceImpl implements NutritionService {

    private final NutritionPlanRepository planRepository;
    private final NutritionLogRepository logRepository;
    private final CheatMealLogRepository cheatMealLogRepository;
    private final MealTemplateRepository templateRepository;
    private final CompensationActionRepository compensationRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final NutritionMapper mapper;

    public NutritionServiceImpl(
            NutritionPlanRepository planRepository,
            NutritionLogRepository logRepository,
            CheatMealLogRepository cheatMealLogRepository,
            MealTemplateRepository templateRepository,
            CompensationActionRepository compensationRepository,
            UserRepository userRepository,
            GoalRepository goalRepository,
            NutritionMapper mapper) {
        this.planRepository = planRepository;
        this.logRepository = logRepository;
        this.cheatMealLogRepository = cheatMealLogRepository;
        this.templateRepository = templateRepository;
        this.compensationRepository = compensationRepository;
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

    // ========== Meal Logging (UC-7.2, UC-7.3) ==========

    @Override
    public NutritionLogResponse logMeal(Long userId, LogMealRequest request) {
        User user = findUserOrThrow(userId);
        
        NutritionLog log = mapper.toEntity(request, user);
        log = logRepository.save(log);

        // Handle cheat meal
        if (Boolean.TRUE.equals(request.getIsCheatMeal())) {
            createCheatMealLog(user, log);
        }

        return mapper.toResponse(log);
    }

    @Override
    public NutritionLogResponse logMealFromTemplate(Long userId, LogMealFromTemplateRequest request) {
        MealTemplate template = templateRepository.findByMealTemplateIdAndNutritionPlanUserUserId(
                request.getTemplateId(), userId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal template not found"));

        float multiplier = request.getQuantityMultiplier() != null ? request.getQuantityMultiplier() : 1.0f;

        LogMealRequest mealRequest = LogMealRequest.builder()
                .mealType(template.getMealType() != null ? 
                        com.dev.backend.model.enums.MealType.valueOf(template.getMealType()) : null)
                .foodName(template.getMealName())
                .calories(Math.round(template.getCalories() * multiplier))
                .proteinG(template.getProteinG() != null ? template.getProteinG() * multiplier : null)
                .carbsG(template.getCarbsG() != null ? template.getCarbsG() * multiplier : null)
                .fatsG(template.getFatsG() != null ? template.getFatsG() * multiplier : null)
                .mealTime(request.getMealTime())
                .logDate(request.getLogDate())
                .isCheatMeal(request.getIsCheatMeal())
                .build();

        return logMeal(userId, mealRequest);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NutritionLogResponse> getDailyLogs(Long userId, LocalDate date) {
        LocalDate logDate = date != null ? date : LocalDate.now();
        return logRepository.findByUserUserIdAndLogDateOrderByMealTimeAsc(userId, logDate)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public DailyNutritionSummaryResponse getDailySummary(Long userId, LocalDate date) {
        LocalDate logDate = date != null ? date : LocalDate.now();

        // Get totals from database using a typed projection to avoid ClassCastException
        com.dev.backend.model.projection.DailyNutritionAggregate aggregate =
                logRepository.getDailySummary(userId, logDate);

        int totalCalories = 0;
        float totalProtein = 0;
        float totalCarbs = 0;
        float totalFats = 0;

        if (aggregate != null) {
            Number caloriesNumber = aggregate.getTotalCalories();
            Number proteinNumber = aggregate.getTotalProtein();
            Number carbsNumber = aggregate.getTotalCarbs();
            Number fatsNumber = aggregate.getTotalFats();

            if (caloriesNumber != null) {
                totalCalories = caloriesNumber.intValue();
            }
            if (proteinNumber != null) {
                totalProtein = proteinNumber.floatValue();
            }
            if (carbsNumber != null) {
                totalCarbs = carbsNumber.floatValue();
            }
            if (fatsNumber != null) {
                totalFats = fatsNumber.floatValue();
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
        long cheatCount = logRepository.countByUserUserIdAndLogDateAndIsCheatMealTrue(userId, logDate);
        builder.cheatMealCount((int) cheatCount);

        return builder.build();
    }

    // ========== Cheat Meal Management (UC-7.3, UC-7.4) ==========

    private void createCheatMealLog(User user, NutritionLog mealLog) {
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
        cheatLog.setNutritionLog(mealLog);
        cheatLog.setUser(user);
        cheatLog.setCheatDate(mealLog.getLogDate());
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

    // ========== Dashboard (UC-7.5) ==========

    @Override
    @Transactional(readOnly = true)
    public NutritionDashboardResponse getDashboard(Long userId) {
        // Today's summary
        DailyNutritionSummaryResponse todaySummary = getDailySummary(userId, LocalDate.now());

        // Recent meals (last 10)
        List<NutritionLogResponse> recentMeals = logRepository
                .findByUserUserIdOrderByLogDateDescMealTimeDesc(userId, 
                        org.springframework.data.domain.PageRequest.of(0, 10))
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());

        // Weekly cheat meal count
        LocalDate weekStart = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        long cheatCount = cheatMealLogRepository.countByUserUserIdAndCheatDateBetween(
                userId, weekStart, LocalDate.now());
        
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(userId).orElse(null);
        int allowedCheatMeals = plan != null && plan.getCheatMealsPerWeek() != null ? 
                plan.getCheatMealsPerWeek() : 2;

        WeeklyCheatMealSummary cheatSummary = WeeklyCheatMealSummary.builder()
                .usedThisWeek((int) cheatCount)
                .allowedPerWeek(allowedCheatMeals)
                .remaining(Math.max(0, allowedCheatMeals - (int) cheatCount))
                .build();

        // Active compensations (cheat meal source only)
        List<CompensationActionResponse> activeCompensations = compensationRepository
                .findByCheatMealLogUserUserIdAndIsCompletedFalse(userId)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());

        // Weekly trends
        NutritionTrendSummary trends = buildTrendSummary(userId);

        return NutritionDashboardResponse.builder()
                .todaySummary(todaySummary)
                .recentMeals(recentMeals)
                .weeklyCheatMeals(cheatSummary)
                .activeCompensations(activeCompensations)
                .trends(trends)
                .build();
    }

    private NutritionTrendSummary buildTrendSummary(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(7);

        List<com.dev.backend.model.projection.DailyNutritionTrendAggregate> dailyTotals =
                logRepository.getDailyTotals(userId, weekAgo, today);

        List<DailyTrendPoint> trendPoints = dailyTotals.stream()
                .map(row -> DailyTrendPoint.builder()
                        .date(row.getLogDate())
                        .calories(row.getTotalCalories() != null ? row.getTotalCalories().intValue() : 0)
                        .proteinG(row.getTotalProtein() != null ? row.getTotalProtein().floatValue() : 0)
                        .carbsG(row.getTotalCarbs() != null ? row.getTotalCarbs().floatValue() : 0)
                        .fatsG(row.getTotalFats() != null ? row.getTotalFats().floatValue() : 0)
                        .build())
                .collect(Collectors.toList());

        float avgCalories = (float) trendPoints.stream()
                .mapToInt(DailyTrendPoint::getCalories)
                .average()
                .orElse(0);

        float avgProtein = (float) trendPoints.stream()
                .mapToDouble(p -> p.getProteinG() != null ? p.getProteinG() : 0)
                .average()
                .orElse(0);

        // Determine adherence status
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(userId).orElse(null);
        String adherenceStatus = "on_track";
        if (plan != null && plan.getDailyCalorieTarget() != null) {
            int target = plan.getDailyCalorieTarget();
            if (avgCalories > target * 1.1) {
                adherenceStatus = "over_target";
            } else if (avgCalories < target * 0.8) {
                adherenceStatus = "under_target";
            }
        }

        return NutritionTrendSummary.builder()
                .last7Days(trendPoints)
                .averageDailyCalories(avgCalories)
                .averageDailyProtein(avgProtein)
                .adherenceStatus(adherenceStatus)
                .build();
    }

    // ========== Meal Templates (UC-7.6) ==========

    @Override
    public MealTemplateResponse createMealTemplate(Long userId, CreateMealTemplateRequest request) {
        NutritionPlan plan = planRepository.findByUserUserIdAndIsActiveTrue(userId)
                .orElseThrow(() -> new ResourceNotFoundException("No active nutrition plan. Create a plan first."));

        MealTemplate template = mapper.toEntity(request, plan);
        template = templateRepository.save(template);
        return mapper.toResponse(template);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MealTemplateResponse> getMealTemplates(Long userId) {
        return templateRepository.findByNutritionPlanUserUserId(userId)
                .stream()
                .map(mapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteMealTemplate(Long userId, Long templateId) {
        MealTemplate template = templateRepository.findByMealTemplateIdAndNutritionPlanUserUserId(templateId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal template not found"));
        templateRepository.delete(template);
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

    // ========== Helper Methods ==========

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}

