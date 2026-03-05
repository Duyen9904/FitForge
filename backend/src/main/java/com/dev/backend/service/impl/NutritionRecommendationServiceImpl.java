package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.DuplicateResourceException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.MealTemplateRepository;
import com.dev.backend.repository.NutritionLogRepository;
import com.dev.backend.repository.NutritionPlanRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingProgressRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.MealTemplateGenerator;
import com.dev.backend.service.NutritionRecommendationService;
import com.dev.backend.service.UserProfileService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class NutritionRecommendationServiceImpl implements NutritionRecommendationService {

    private final UserProfileService userProfileService;
    private final UserRepository userRepository;
    private final NutritionPlanRepository nutritionPlanRepository;
    private final NutritionLogRepository nutritionLogRepository;
    private final GoalRepository goalRepository;
    private final MealTemplateRepository mealTemplateRepository;
    private final MealTemplateGenerator mealTemplateGenerator;
    private final UserOnboardingProgressRepository progressRepository;
    private final OnboardingStepRepository stepRepository;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public NutritionPlan generateInitialPlan(Long userId) {
        log.info("Generating initial nutrition plan for user: {}", userId);

        // Enforce single active nutrition plan per user.
        // If a plan already exists, surface a clear business error instead of
        // letting the database unique constraint fail with a 500.
        if (nutritionPlanRepository.existsByUserUserId(userId)) {
            throw new DuplicateResourceException("User already has a nutrition plan. Use update or adjust endpoints instead.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        UserProfile profile = userProfileService.buildProfile(userId);

        // Estimate maintenance calories using Mifflin-St Jeor equation
        int maintenanceCalories = estimateMaintenanceCalories(profile);

        // Adjust for goal
        int targetCalories = maintenanceCalories;
        String adjustmentReason = "Maintenance calories estimated at " + maintenanceCalories + " based on profile. ";

        if (profile.getPrimaryGoalName() != null) {
            String goalName = profile.getPrimaryGoalName().toUpperCase();
            if (goalName.contains("LOSE") || goalName.contains("FAT_LOSS") || goalName.contains("WEIGHT_LOSS")) {
                targetCalories = (int) (maintenanceCalories * 0.85); // -15%
                adjustmentReason += "Fat loss goal: reducing by 15%. ";
            } else if (goalName.contains("GAIN") || goalName.contains("MUSCLE") || goalName.contains("BULK")) {
                targetCalories = (int) (maintenanceCalories * 1.10); // +10%
                adjustmentReason += "Muscle gain goal: increasing by 10%. ";
            }
        }

        // Set macro ratios based on goal
        float proteinPercentage = 30f; // Default
        float carbsPercentage = 40f;
        float fatsPercentage = 30f;

        if (profile.getPrimaryGoalName() != null && profile.getPrimaryGoalName().toUpperCase().contains("MUSCLE")) {
            proteinPercentage = 35f;
            carbsPercentage = 40f;
            fatsPercentage = 25f;
        } else if (profile.getPrimaryGoalName() != null && profile.getPrimaryGoalName().toUpperCase().contains("FAT")) {
            proteinPercentage = 35f;
            carbsPercentage = 30f;
            fatsPercentage = 35f;
        }

        // Create nutrition plan
        NutritionPlan plan = new NutritionPlan();
        plan.setUser(user);
        plan.setPlanName("Personalized Nutrition Plan");
        plan.setDailyCalorieTarget(targetCalories);
        plan.setProteinPercentage(proteinPercentage);
        plan.setCarbsPercentage(carbsPercentage);
        plan.setFatsPercentage(fatsPercentage);
        plan.setCheatMealsPerWeek(2); // Default
        plan.setAutoAdjustEnabled(true);
        plan.setIsActive(true);
        plan.setAlgorithmVersion("RULE_BASED_V1");
        plan.setVersion(1);
        plan.setRecommendationReason(adjustmentReason.trim());

        // Link to user's primary goal (with fallback)
        plan.setGoal(getOrFetchUserGoal(user));

        plan = nutritionPlanRepository.save(plan);
        log.info("Generated initial nutrition plan {} for user {}", plan.getNutritionPlanId(), userId);

        // NEW: Generate meal templates for Day 1 only (lightweight initial load)
        try {
            List<MealTemplate> mealTemplates = mealTemplateGenerator.generateDayMeals(plan, 1);
            
            // Save meal templates (standalone system entries)
            mealTemplateRepository.saveAll(mealTemplates);
            
            log.info("Generated {} meal templates (Day 1) for plan {}", mealTemplates.size(), plan.getNutritionPlanId());
        } catch (Exception e) {
            log.error("Error generating meal templates for plan {}", plan.getNutritionPlanId(), e);
            // Continue without meal templates - they can be generated on-demand
        }

        return plan;
    }

    @Override
    @Transactional
    public NutritionPlan adjustPlanBasedOnBehavior(Long userId, Long planId) {
        log.info("Adjusting nutrition plan {} for user {} based on behavior", planId, userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        NutritionPlan currentPlan = nutritionPlanRepository.findById(planId)
                .filter(p -> p.getUser().getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("NutritionPlan not found: " + planId));

        // Analyze adherence over last 7 days
        LocalDate weekAgo = LocalDate.now().minusDays(7);
        LocalDate today = LocalDate.now();

        // Adherence based on distinct logged days in range
        long loggedDays = nutritionLogRepository.countDistinctLogDatesByUserAndDateRange(userId, weekAgo, today);
        float adherence = loggedDays / 7.0f;

        log.info("User {} nutrition adherence over last week: {}", userId, adherence);

        // Decide if adjustment is needed
        boolean needsAdjustment = false;
        StringBuilder adjustmentReason = new StringBuilder();

        // Rule 1: Low adherence (< 50%) → suggest easier targets (no calorie change yet)
        if (adherence < 0.5f) {
            adjustmentReason.append("Low logging adherence - consider setting reminders. ");
            // No structural change yet, just messaging
        }

        // Rule 2: High adherence (> 80%) + off-target weight trend
        // This requires weight tracking integration, which we'll stub for now
        // In production, compare weight trend vs goal
        if (adherence > 0.8f) {
            adjustmentReason.append("High adherence maintained. ");
            // TODO: Compare weight trend and adjust calories by ±100-200 if off-target
        }

        if (adjustmentReason.length() == 0) {
            log.info("No adjustment needed for nutrition plan {}", planId);
            return currentPlan;
        }

        // For now, we don't create a new plan unless there's a structural change
        // Just update the reason field
        currentPlan.setRecommendationReason(adjustmentReason.toString().trim());
        currentPlan = nutritionPlanRepository.save(currentPlan);

        log.info("Updated nutrition plan {} with behavior notes", planId);
        return currentPlan;
    }

    private int estimateMaintenanceCalories(UserProfile profile) {
        // Mifflin-St Jeor equation
        // Men: 10 * weight(kg) + 6.25 * height(cm) - 5 * age + 5
        // Women: 10 * weight(kg) + 6.25 * height(cm) - 5 * age - 161

        if (profile.getCurrentWeightKg() == null || profile.getHeightCm() == null || profile.getAgeYears() == null) {
            return 2000; // Default fallback
        }

        float weight = profile.getCurrentWeightKg();
        float height = profile.getHeightCm();
        int age = profile.getAgeYears();
        String gender = profile.getGender();

        float bmr;
        if ("FEMALE".equalsIgnoreCase(gender) || "F".equalsIgnoreCase(gender)) {
            bmr = 10 * weight + 6.25f * height - 5 * age - 161;
        } else {
            bmr = 10 * weight + 6.25f * height - 5 * age + 5;
        }

        // Apply activity multiplier (default moderate activity)
        float activityMultiplier = 1.55f; // Moderate (exercise 3-5 days/week)
        if (profile.getScheduleDays() != null) {
            int daysPerWeek = profile.getScheduleDays().size();
            if (daysPerWeek <= 2) {
                activityMultiplier = 1.375f; // Light
            } else if (daysPerWeek >= 5) {
                activityMultiplier = 1.725f; // Very active
            }
        }

        return Math.round(bmr * activityMultiplier);
    }

    @Override
    @Transactional
    public List<MealTemplate> getOrGenerateMealsForDay(Long userId, Long planId, int dayNumber) {
        log.info("Getting or generating meals for plan {}, day {}", planId, dayNumber);

        // Verify user owns the plan
        NutritionPlan plan = nutritionPlanRepository.findById(planId)
                .orElseThrow(() -> new ResourceNotFoundException("NutritionPlan not found: " + planId));

        if (!plan.getUser().getUserId().equals(userId)) {
            throw new ResourceNotFoundException("NutritionPlan not found for user: " + userId);
        }

        // Check if meals already exist (system-level templates)
        List<MealTemplate> existing = mealTemplateRepository.findAll();
        
        if (!existing.isEmpty()) {
            log.info("Found {} existing meal templates", existing.size());
            return existing;
        }

        // Generate on-demand
        log.info("Generating new meal templates for day {}", dayNumber);
        try {
            List<MealTemplate> meals = mealTemplateGenerator.generateDayMeals(plan, dayNumber);
            return mealTemplateRepository.saveAll(meals);
        } catch (Exception e) {
            log.error("Error generating meals for day {}", dayNumber, e);
            throw new RuntimeException("Failed to generate meal templates for day " + dayNumber, e);
        }
    }

    /**
     * Extract goal from onboarding progress JSON data.
     * Returns null if not found or parsing fails.
     */
    private Goal extractGoalFromOnboarding(User user) {
        try {
            // Get all onboarding progress for user
            List<UserOnboardingProgress> progressList = progressRepository.findByUserUserId(user.getUserId());
            
            // Find FITNESS_GOAL step
            Optional<UserOnboardingProgress> goalProgress = progressList.stream()
                    .filter(p -> p.getStep().getStepType() == OnboardingStepType.FITNESS_GOAL)
                    .findFirst();
            
            if (goalProgress.isEmpty() || goalProgress.get().getResponseData() == null) {
                log.debug("No FITNESS_GOAL onboarding data found for user {}", user.getUserId());
                return null;
            }
            
            String responseData = goalProgress.get().getResponseData();
            JsonNode root = objectMapper.readTree(responseData);
            
            // Parse goal using same logic as OnboardingServiceImpl
            String goalName = null;
            Long goalId = null;
            
            if (root.has("goalId")) {
                goalId = root.get("goalId").asLong();
            } else if (root.has("selected")) {
                JsonNode selected = root.get("selected");
                if (selected.isArray() && selected.size() > 0) {
                    JsonNode firstGoal = selected.get(0);
                    if (firstGoal.isObject()) {
                        if (firstGoal.has("goalId")) {
                            goalId = firstGoal.get("goalId").asLong();
                        } else if (firstGoal.has("id")) {
                            goalId = firstGoal.get("id").asLong();
                        } else if (firstGoal.has("name")) {
                            goalName = firstGoal.get("name").asText();
                        }
                    } else if (firstGoal.isTextual()) {
                        goalName = firstGoal.asText();
                    } else if (firstGoal.isNumber()) {
                        goalId = firstGoal.asLong();
                    }
                } else if (selected.isTextual()) {
                    goalName = selected.asText();
                } else if (selected.isNumber()) {
                    goalId = selected.asLong();
                }
            } else if (root.has("goalName")) {
                goalName = root.get("goalName").asText();
            } else if (root.has("name")) {
                goalName = root.get("name").asText();
            }
            
            // Lookup goal
            Optional<Goal> goalOpt = Optional.empty();
            if (goalId != null) {
                goalOpt = goalRepository.findById(goalId);
            }
            if (goalOpt.isEmpty() && goalName != null && !goalName.isBlank()) {
                goalOpt = goalRepository.findByGoalName(goalName);
            }
            
            if (goalOpt.isPresent()) {
                log.info("Extracted goal from onboarding for user {}: {}", user.getUserId(), goalOpt.get().getGoalName());
                return goalOpt.get();
            } else {
                log.warn("Could not find goal from onboarding data. goalId={}, goalName={}, user={}", 
                        goalId, goalName, user.getUserId());
                return null;
            }
        } catch (Exception e) {
            log.error("Error extracting goal from onboarding for user {}: {}", user.getUserId(), e.getMessage(), e);
            return null;
        }
    }

    /**
     * Get user's goal with 3-level fallback:
     * 1. Check User.primaryGoal FK (fast)
     * 2. Extract from onboarding JSON and sync back to FK
     * 3. Use default goal or throw exception
     */
    private Goal getOrFetchUserGoal(User user) {
        // Level 1: Check FK (fast)
        if (user.getPrimaryGoal() != null) {
            log.debug("Using primary goal from User FK for user {}: {}", 
                    user.getUserId(), user.getPrimaryGoal().getGoalName());
            return user.getPrimaryGoal();
        }
        
        log.warn("User {} has no primary goal set in FK. Attempting to extract from onboarding...", user.getUserId());
        
        // Level 2: Extract from onboarding JSON
        Goal onboardingGoal = extractGoalFromOnboarding(user);
        if (onboardingGoal != null) {
            log.info("Auto-syncing goal from onboarding to User FK for user {}: {}", 
                    user.getUserId(), onboardingGoal.getGoalName());
            // Auto-sync back to FK
            user.setPrimaryGoal(onboardingGoal);
            userRepository.save(user);
            return onboardingGoal;
        }
        
        // Level 3: Try default goal
        log.warn("No goal found in onboarding for user {}. Checking for default goal...", user.getUserId());
        Optional<Goal> defaultGoal = goalRepository.findByGoalName("General Fitness");
        if (defaultGoal.isPresent()) {
            log.warn("Using default goal 'General Fitness' for user {}", user.getUserId());
            return defaultGoal.get();
        }
        
        // No goal available - throw exception
        throw new BadRequestException(
                "No fitness goal set. Please complete onboarding or set your fitness goal in your profile.");
    }
}
