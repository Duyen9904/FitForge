package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.dto.response.WorkoutTemplateSummaryResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.*;
import com.dev.backend.service.ExerciseAPIService;
import com.dev.backend.service.UserProfileService;
import com.dev.backend.service.WorkoutRecommendationService;
import com.dev.backend.service.WorkoutSessionGenerator;
import com.dev.backend.service.WorkoutTemplateRanker;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkoutRecommendationServiceImpl implements WorkoutRecommendationService {

    private final UserProfileService userProfileService;
    private final WorkoutTemplateRanker templateRanker;
    private final UserRepository userRepository;
    private final WorkoutPlanRepository workoutPlanRepository;
    private final WorkoutSessionLogRepository sessionLogRepository;
    private final ExercisePerformanceLogRepository performanceLogRepository;
    private final WorkoutSessionRepository workoutSessionRepository;
    private final ExerciseAPIService exerciseAPIService;
    private final WorkoutSessionGenerator workoutSessionGenerator;
    private final UserOnboardingProgressRepository progressRepository;
    private final OnboardingStepRepository stepRepository;
    private final GoalRepository goalRepository;
    private final ObjectMapper objectMapper;
    private final WorkoutProgressRepository workoutProgressRepository;
    private final WorkoutPlanMapper workoutPlanMapper;
    private final MissedWorkoutRepository missedWorkoutRepository;
    private final MuscleGroupRepository muscleGroupRepository;

    @Override
    @Transactional
    public WorkoutPlan generateInitialPlan(Long userId, LocalDate startDate) {
        log.info("Generating initial workout plan for user: {} with start date: {}", userId, startDate);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        UserProfile profile = userProfileService.buildProfile(userId);

        // Rank templates by user profile
        List<WorkoutTemplate> topTemplates = templateRanker.rankTemplatesForUser(profile, 1);
        if (topTemplates.isEmpty()) {
            // Fallback: create a baseline plan directly from onboarding/user profile.
            // This ensures the API can still return a usable plan even when templates are missing or no template matches.
            WorkoutPlan fallbackPlan = new WorkoutPlan();
            fallbackPlan.setUser(user);
            fallbackPlan.setPlanName("Starter Plan - Personalized");
            fallbackPlan.setDescription("Baseline full body plan generated from your onboarding profile.");
            String fallbackGroupName = "Full Body";
            MuscleGroup fallbackMuscleGroup = muscleGroupRepository.findByGroupName(fallbackGroupName)
                    .orElseThrow(() -> new BadRequestException("No MuscleGroup configured for target " + fallbackGroupName));
            fallbackPlan.setMuscleGroup(fallbackMuscleGroup);

            int frequency = 3;
            if (profile.getScheduleDays() != null && !profile.getScheduleDays().isEmpty()) {
                frequency = profile.getScheduleDays().size();
            }
            fallbackPlan.setFrequencyPerWeek(frequency);

            fallbackPlan.setDurationWeeks(12);
            fallbackPlan.setDifficultyLevel(profile.getFitnessLevel() != null ? profile.getFitnessLevel() : "BEGINNER");
            fallbackPlan.setStartDate(startDate);
            fallbackPlan.setAiGenerated(false);
            fallbackPlan.setAllowWorkoutSwaps(true);
            fallbackPlan.setIsActive(true);
            fallbackPlan.setAlgorithmVersion("RULE_BASED_V1");
            fallbackPlan.setGeneratedFrom("FALLBACK_NO_TEMPLATE");
            fallbackPlan.setVersion(1);
            fallbackPlan.setRecommendationReason("No matching workout template found; generated a baseline plan from onboarding data.");

            fallbackPlan.setGoal(getOrFetchUserGoal(user));

            fallbackPlan = workoutPlanRepository.save(fallbackPlan);
            log.info("Generated fallback workout plan {} for user {}", fallbackPlan.getPlanId(), userId);
            
            // Generate a full week of sessions for fallback plan
            try {
                List<Exercise> selectedExercises = exerciseAPIService.selectExercisesForPlan(fallbackPlan);
                List<WorkoutSession> sessions = generateFullWeekSessions(fallbackPlan, selectedExercises);

                for (WorkoutSession session : sessions) {
                    session.setWorkoutPlan(fallbackPlan);
                    session.setScheduledDate(startDate.plusDays(session.getDayNumber() - 1));
                }
                workoutSessionRepository.saveAll(sessions);
                fallbackPlan.getWorkoutSessions().addAll(sessions);
                
                log.info("Generated {} workout sessions (full week) for fallback plan {}", sessions.size(), fallbackPlan.getPlanId());
            } catch (Exception e) {
                log.error("Error generating workout sessions for fallback plan {}", fallbackPlan.getPlanId(), e);
            }
            
            return fallbackPlan;
        }

        WorkoutTemplate bestTemplate = topTemplates.get(0);
        String explanation = templateRanker.explainRecommendation(bestTemplate, profile);

        // Create WorkoutPlan from template
        WorkoutPlan plan = new WorkoutPlan();
        plan.setUser(user);
        plan.setPlanName(bestTemplate.getName() + " - Personalized");
        plan.setDescription(bestTemplate.getDescription());
        final String templateGroupName;
        if (bestTemplate.getPrimaryMuscleGroups() != null && !bestTemplate.getPrimaryMuscleGroups().isBlank()) {
            templateGroupName = bestTemplate.getPrimaryMuscleGroups().split(",")[0].trim();
        } else {
            templateGroupName = "Full Body";
        }
        MuscleGroup templateMuscleGroup = muscleGroupRepository.findByGroupName(templateGroupName)
                .orElseThrow(() -> new BadRequestException("No MuscleGroup configured for target " + templateGroupName));
        plan.setMuscleGroup(templateMuscleGroup);
        plan.setFrequencyPerWeek(bestTemplate.getDaysPerWeek());
        plan.setDurationWeeks(12); // Default 12-week program
        plan.setDifficultyLevel(bestTemplate.getExperienceLevel());
        plan.setStartDate(startDate);
        plan.setAiGenerated(false);
        plan.setAllowWorkoutSwaps(true);
        plan.setIsActive(true);
        plan.setAlgorithmVersion("RULE_BASED_V1");
        plan.setGeneratedFrom("ONBOARDING_ONLY");
        plan.setVersion(1);
        plan.setRecommendationReason(explanation);

        // Link to user's primary goal (with fallback)
        plan.setGoal(getOrFetchUserGoal(user));

        plan = workoutPlanRepository.save(plan);
        log.info("Generated initial workout plan {} for user {}", plan.getPlanId(), userId);

        // Generate a full week of workout sessions (Day 1-7)
        try {
            List<Exercise> selectedExercises = exerciseAPIService.selectExercisesForPlan(plan);
            List<WorkoutSession> sessions = generateFullWeekSessions(plan, selectedExercises);

            for (WorkoutSession session : sessions) {
                session.setWorkoutPlan(plan);
                session.setScheduledDate(startDate.plusDays(session.getDayNumber() - 1));
            }
            workoutSessionRepository.saveAll(sessions);
            plan.getWorkoutSessions().addAll(sessions);
            
            log.info("Generated {} workout sessions (full week) for plan {}", sessions.size(), plan.getPlanId());
        } catch (Exception e) {
            log.error("Error generating workout sessions for plan {}", plan.getPlanId(), e);
            // Continue without sessions - they can be generated on-demand
        }

        return plan;
    }

    @Override
    @Transactional(readOnly = true)
    public List<WorkoutTemplateSummaryResponse> getRecommendedTemplates(Long userId, int limit) {
        if (limit <= 0) {
            limit = 5;
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        UserProfile profile = userProfileService.buildProfile(userId);

        List<WorkoutTemplate> templates = templateRanker.rankTemplatesForUser(profile, limit);

        if (templates.isEmpty()) {
            return List.of();
        }

        return templates.stream()
                .map(template -> WorkoutTemplateSummaryResponse.builder()
                        .id(template.getTemplateId())
                        .name(template.getName())
                        .goalType(template.getGoalType())
                        .experienceLevel(template.getExperienceLevel())
                        .daysPerWeek(template.getDaysPerWeek())
                        .equipmentTags(template.getEquipmentTags())
                        .recommendationReason(templateRanker.explainRecommendation(template, profile))
                        .build())
                .collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional
    public WorkoutPlan adjustPlanBasedOnBehavior(Long userId, Long planId) {
        log.info("Adjusting workout plan {} for user {} based on behavior", planId, userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        WorkoutPlan currentPlan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan not found: " + planId));

        // Analyze behavior over last 2 weeks
        Instant twoWeeksAgo = Instant.now().minus(14, ChronoUnit.DAYS);
        Long sessionCount = sessionLogRepository.countSessionsSince(userId, planId, twoWeeksAgo);
        Float avgCompletionRate = sessionLogRepository.avgCompletionRate(userId, planId, twoWeeksAgo);
        Float avgRPE = sessionLogRepository.avgRPE(userId, planId, twoWeeksAgo);

        // Check for pain flags
        List<ExercisePerformanceLog> painLogs = performanceLogRepository.findPainFlagsSince(userId, twoWeeksAgo);

        // Compute adherence metrics
        int expectedSessions = currentPlan.getFrequencyPerWeek() * 2; // 2 weeks
        float workoutAdherence = sessionCount != null && expectedSessions > 0 ?
                (float) sessionCount / expectedSessions : 0f;

        log.info("User {} adherence: {}, avgCompletionRate: {}, avgRPE: {}",
                userId, workoutAdherence, avgCompletionRate, avgRPE);

        // Decide if adjustment is needed
        boolean needsAdjustment = false;
        StringBuilder adjustmentReason = new StringBuilder();

        // Rule 1: Low adherence → reduce frequency
        if (workoutAdherence < 0.5f && sessionCount > 0) {
            needsAdjustment = true;
            adjustmentReason.append("Low adherence (")
                    .append(String.format("%.0f%%", workoutAdherence * 100))
                    .append(") over 2 weeks - reducing days/week. ");
        }

        // Rule 2: High adherence + moderate RPE → small progression
        if (workoutAdherence > 0.9f && avgRPE != null && avgRPE <= 6.5f && sessionCount >= 6) {
            needsAdjustment = true;
            adjustmentReason.append("High adherence with moderate RPE - increasing intensity. ");
        }

        // Rule 3: Recurring pain → swap exercises
        if (!painLogs.isEmpty() && painLogs.size() >= 2) {
            needsAdjustment = true;
            adjustmentReason.append("Recurring pain flags detected - plan adjustment recommended. ");
        }

        if (!needsAdjustment) {
            log.info("No adjustment needed for plan {}", planId);
            return currentPlan;
        }

        // Apply adjustment: create new version of plan
        WorkoutPlan adjustedPlan = new WorkoutPlan();
        adjustedPlan.setUser(user);
        adjustedPlan.setGoal(currentPlan.getGoal());
        adjustedPlan.setPlanName(currentPlan.getPlanName() + " (Adjusted v" + (currentPlan.getVersion() + 1) + ")");
        adjustedPlan.setDescription(currentPlan.getDescription());
        adjustedPlan.setMuscleGroup(currentPlan.getMuscleGroup());

        // Adjust frequency based on adherence
        int newFrequency = currentPlan.getFrequencyPerWeek();
        if (workoutAdherence < 0.5f && newFrequency > 2) {
            newFrequency = Math.max(2, newFrequency - 1);
        } else if (workoutAdherence > 0.9f && newFrequency < 6) {
            newFrequency = Math.min(6, newFrequency + 1);
        }

        adjustedPlan.setFrequencyPerWeek(newFrequency);
        adjustedPlan.setDurationWeeks(currentPlan.getDurationWeeks());
        adjustedPlan.setDifficultyLevel(currentPlan.getDifficultyLevel());
        adjustedPlan.setStartDate(currentPlan.getStartDate());
        adjustedPlan.setAiGenerated(currentPlan.getAiGenerated());
        adjustedPlan.setAllowWorkoutSwaps(true);
        adjustedPlan.setIsActive(true);
        adjustedPlan.setAlgorithmVersion("RULE_BASED_V1");
        adjustedPlan.setGeneratedFrom("ONBOARDING_PLUS_BEHAVIOR");
        adjustedPlan.setVersion(currentPlan.getVersion() + 1);
        adjustedPlan.setRecommendationReason(adjustmentReason.toString().trim());

        adjustedPlan = workoutPlanRepository.save(adjustedPlan);

        // Deactivate old plan
        currentPlan.setIsActive(false);
        workoutPlanRepository.save(currentPlan);

        log.info("Adjusted workout plan: new plan ID {}, reason: {}", adjustedPlan.getPlanId(), adjustmentReason);
        return adjustedPlan;
    }

    @Override
    @Transactional
    public WorkoutSession getOrGenerateSessionForDay(Long userId, Long planId, int dayNumber) {
        log.info("Getting or generating workout session for plan {}, day {}", planId, dayNumber);

        // Verify user owns the plan
        WorkoutPlan plan = workoutPlanRepository.findById(planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan not found: " + planId));

        if (!plan.getUser().getUserId().equals(userId)) {
            throw new ResourceNotFoundException("WorkoutPlan not found for user: " + userId);
        }

        // Check if session already exists
        var existing = workoutSessionRepository.findByPlanIdAndDayNumber(planId, dayNumber);
        if (existing.isPresent()) {
            log.info("Found existing session for day {}", dayNumber);
            return existing.get();
        }

        // Generate on-demand
        log.info("Generating new session for day {}", dayNumber);
        try {
            List<Exercise> exercises = exerciseAPIService.selectExercisesForPlan(plan);
            WorkoutSession session = workoutSessionGenerator.generateSessionForDay(plan, exercises, dayNumber);
            session.setWorkoutPlan(plan);
            
            if (plan.getStartDate() != null) {
                session.setScheduledDate(plan.getStartDate().plusDays(dayNumber - 1));
            }
            
            return workoutSessionRepository.save(session);
        } catch (Exception e) {
            log.error("Error generating session for day {}", dayNumber, e);
            throw new RuntimeException("Failed to generate workout session for day " + dayNumber, e);
        }
    }

    @Override
    @Transactional
    public List<WorkoutSession> getOrGenerateSessionsForWeek(Long userId, Long planId, int weekNumber) {
        log.info("Getting or generating sessions for plan {}, week {}", planId, weekNumber);

        WorkoutPlan plan = workoutPlanRepository.findById(planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan not found: " + planId));

        if (!plan.getUser().getUserId().equals(userId)) {
            throw new ResourceNotFoundException("WorkoutPlan not found for user: " + userId);
        }

        if (weekNumber < 1 || weekNumber > plan.getDurationWeeks()) {
            throw new BadRequestException(
                    "Week number must be between 1 and " + plan.getDurationWeeks() + " for this plan");
        }

        int startDay = (weekNumber - 1) * 7 + 1;
        List<WorkoutSession> weekSessions = new ArrayList<>();

        for (int day = startDay; day < startDay + 7; day++) {
            final int currentDay = day;
            Optional<WorkoutSession> existing = workoutSessionRepository.findByPlanIdAndDayNumber(planId, currentDay);

            if (existing.isPresent()) {
                weekSessions.add(existing.get());
            } else {
                try {
                    List<Exercise> exercises = exerciseAPIService.selectExercisesForPlan(plan);
                    WorkoutSession session = workoutSessionGenerator.generateSessionForDay(plan, exercises, currentDay);
                    session.setWorkoutPlan(plan);
                    if (plan.getStartDate() != null) {
                        session.setScheduledDate(plan.getStartDate().plusDays(currentDay - 1));
                    }
                    weekSessions.add(workoutSessionRepository.save(session));
                } catch (Exception e) {
                    log.error("Error generating session for day {}", currentDay, e);
                    throw new RuntimeException("Failed to generate workout session for day " + currentDay, e);
                }
            }
        }

        log.info("Returned {} sessions for plan {} week {}", weekSessions.size(), planId, weekNumber);
        return weekSessions;
    }

    @Override
    @Transactional
    public List<WorkoutSessionResponse> getWeekSessionsWithCompletion(Long userId, Long planId, int weekNumber) {
        List<WorkoutSession> sessions = getOrGenerateSessionsForWeek(userId, planId, weekNumber);
        Set<Long> completedSessionIds = new HashSet<>(workoutProgressRepository.findCompletedSessionIdsByUserAndPlan(userId, planId));

        // Build map of sessionId → missedWorkoutId
        java.util.Map<Long, Long> missedMap = new java.util.HashMap<>();
        for (WorkoutSession s : sessions) {
            missedWorkoutRepository.findByUserUserIdAndWorkoutSessionSessionId(userId, s.getSessionId())
                .ifPresent(mw -> missedMap.put(s.getSessionId(), mw.getMissedWorkoutId()));
        }

        return sessions.stream()
                .map(session -> workoutPlanMapper.toSessionResponse(
                        session,
                        completedSessionIds.contains(session.getSessionId()),
                        missedMap.get(session.getSessionId())))
                .collect(Collectors.toList());
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
     * Generate a full week of workout sessions (7 days) based on frequencyPerWeek.
     * Workout days are distributed evenly across the week, with rest days filling gaps.
     * @param plan the workout plan
     * @param exercises available exercises
     * @return list of 7 workout sessions
     */
    private List<WorkoutSession> generateFullWeekSessions(WorkoutPlan plan, List<Exercise> exercises) {
        List<WorkoutSession> allSessions = new java.util.ArrayList<>();
        int frequencyPerWeek = plan.getFrequencyPerWeek();
        
        // Determine which days are workout days (spread evenly across the week)
        Set<Integer> workoutDays = distributeWorkoutDays(frequencyPerWeek);
        
        for (int day = 1; day <= 7; day++) {
            WorkoutSession session;
            
            if (workoutDays.contains(day)) {
                // Generate actual workout session
                session = workoutSessionGenerator.generateSessionForDay(plan, exercises, day);
            } else {
                // Create rest day session
                session = new WorkoutSession();
                session.setWorkoutPlan(plan);
                session.setDayNumber(day);
                session.setSessionName("Rest Day");
                session.setFocusArea("Recovery");
                session.setEstimatedDuration(0);
                session.setWarmUpNotes(null);
                session.setCoolDownNotes(null);
                session.setIsRestDay(true);
            }
            
            allSessions.add(session);
        }
        
        return allSessions;
    }

    /**
     * Distribute workout days evenly across a week based on frequency.
     * @param frequencyPerWeek number of workout days per week
     * @return set of day numbers (1-7) that should be workout days
     */
    private Set<Integer> distributeWorkoutDays(int frequencyPerWeek) {
        Set<Integer> workoutDays = new HashSet<>();
        
        if (frequencyPerWeek <= 0) {
            return workoutDays;
        }
        
        if (frequencyPerWeek >= 7) {
            // All days are workout days
            for (int i = 1; i <= 7; i++) {
                workoutDays.add(i);
            }
            return workoutDays;
        }
        
        // Distribute workouts evenly across the week
        double interval = 7.0 / frequencyPerWeek;
        for (int i = 0; i < frequencyPerWeek; i++) {
            int dayNumber = (int) Math.round(i * interval) + 1;
            // Ensure day is within 1-7 range
            dayNumber = Math.min(Math.max(dayNumber, 1), 7);
            workoutDays.add(dayNumber);
        }
        
        // If we still don't have enough days due to rounding, add more starting from day 1
        int day = 1;
        while (workoutDays.size() < frequencyPerWeek && day <= 7) {
            workoutDays.add(day);
            day++;
        }
        
        return workoutDays;
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
