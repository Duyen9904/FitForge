package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.ai.AiExerciseSlot;
import com.dev.backend.model.dto.ai.AiPlanGenerationContext;
import com.dev.backend.model.dto.ai.AiSessionStructure;
import com.dev.backend.model.dto.ai.AiStructureResult;
import com.dev.backend.model.dto.ai.AiWorkoutPlanResult;
import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.WorkoutPlanDetailResponse;
import com.dev.backend.model.dto.response.WorkoutPlanResponse;
import com.dev.backend.model.dto.response.WorkoutPlanStatsResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryResponse;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.PlanGenerationStrategy;
import com.dev.backend.repository.*;
import com.dev.backend.service.AiService;
import com.dev.backend.service.ExerciseSelector;
import com.dev.backend.service.UserProfileService;
import com.dev.backend.service.WorkoutDateCalculator;
import com.dev.backend.service.WorkoutPlanService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class WorkoutPlanServiceImpl implements WorkoutPlanService {

    private final WorkoutPlanRepository workoutPlanRepository;
    private final WorkoutSessionRepository workoutSessionRepository;
    private final SessionExerciseRepository sessionExerciseRepository;
    private final GoalRepository goalRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserRepository userRepository;
    private final MuscleGroupRepository muscleGroupRepository;
    private final WorkoutPlanMapper workoutPlanMapper;
    private final WorkoutDateCalculator workoutDateCalculator;
    private final AiService aiService;
    private final ExerciseSelector exerciseSelector;
    private final UserProfileService userProfileService;
    private final WorkoutSessionLogRepository workoutSessionLogRepository;

    public WorkoutPlanServiceImpl(WorkoutPlanRepository workoutPlanRepository,
                                  WorkoutSessionRepository workoutSessionRepository,
                                  SessionExerciseRepository sessionExerciseRepository,
                                  GoalRepository goalRepository,
                                  ExerciseRepository exerciseRepository,
                                  UserRepository userRepository,
                                  MuscleGroupRepository muscleGroupRepository,
                                  WorkoutPlanMapper workoutPlanMapper,
                                  WorkoutDateCalculator workoutDateCalculator,
                                  AiService aiService,
                                  ExerciseSelector exerciseSelector,
                                  UserProfileService userProfileService,
                                  WorkoutSessionLogRepository workoutSessionLogRepository) {
        this.workoutPlanRepository = workoutPlanRepository;
        this.workoutSessionRepository = workoutSessionRepository;
        this.sessionExerciseRepository = sessionExerciseRepository;
        this.goalRepository = goalRepository;
        this.exerciseRepository = exerciseRepository;
        this.userRepository = userRepository;
        this.muscleGroupRepository = muscleGroupRepository;
        this.workoutPlanMapper = workoutPlanMapper;
        this.workoutDateCalculator = workoutDateCalculator;
        this.aiService = aiService;
        this.exerciseSelector = exerciseSelector;
        this.userProfileService = userProfileService;
        this.workoutSessionLogRepository = workoutSessionLogRepository;
    }

    @Override
    @Transactional
    public WorkoutPlanResponse createPlan(Long userId, CreateWorkoutPlanRequest request) {
        log.info("Creating workout plan for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        Goal goal = goalRepository.findById(request.getGoalId())
                .orElseThrow(() -> new ResourceNotFoundException("Goal", "id", request.getGoalId()));

        MuscleGroup muscleGroup = muscleGroupRepository.findById(request.getMuscleGroupId())
                .orElseThrow(() -> new ResourceNotFoundException("MuscleGroup", "id", request.getMuscleGroupId()));

        // Create workout plan (sessions and exercises added separately via dedicated endpoints)
        WorkoutPlan plan = workoutPlanMapper.toEntity(request, user, goal, muscleGroup);
        plan = workoutPlanRepository.save(plan);

        log.info("Created workout plan with ID: {}", plan.getPlanId());
        return workoutPlanMapper.toResponse(plan);
    }

    @Override
    @Transactional
    public WorkoutSessionResponse addSession(Long userId, Long planId, CreateWorkoutSessionRequest request) {
        log.info("Adding session to plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutPlanMapper.toSessionEntity(request, plan);
        LocalDate scheduledDate = workoutDateCalculator.calculateDateForDayNumber(
                plan.getStartDate(),
                request.getDayNumber(),
                plan.getFrequencyPerWeek()
        );
        session.setScheduledDate(scheduledDate);
        session = workoutSessionRepository.save(session);

        if (request.getExercises() != null && !request.getExercises().isEmpty()) {
            List<SessionExercise> exercises = new ArrayList<>();
            for (CreateSessionExerciseRequest exerciseRequest : request.getExercises()) {
                Exercise exercise = exerciseRepository.findById(exerciseRequest.getExerciseId())
                        .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseRequest.getExerciseId()));
                SessionExercise sessionExercise = workoutPlanMapper.toSessionExerciseEntity(exerciseRequest, session, exercise);
                exercises.add(sessionExerciseRepository.save(sessionExercise));
            }
            session.getSessionExercises().addAll(exercises);
        }

        plan.getWorkoutSessions().add(session);
        log.info("Added session {} to plan {}", session.getSessionId(), planId);
        return workoutPlanMapper.toSessionResponse(session);
    }

    @Override
    @Transactional
    public WorkoutSessionResponse addExercises(Long userId, Long planId, Long sessionId, List<CreateSessionExerciseRequest> exercises) {
        log.info("Adding exercises to session {} in plan {} for user: {}", sessionId, planId, userId);

        workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        if (exercises == null || exercises.isEmpty()) {
            throw new BadRequestException("At least one exercise is required");
        }

        List<SessionExercise> created = new ArrayList<>();
        for (CreateSessionExerciseRequest exerciseRequest : exercises) {
            Exercise exercise = exerciseRepository.findById(exerciseRequest.getExerciseId())
                    .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseRequest.getExerciseId()));
            SessionExercise sessionExercise = workoutPlanMapper.toSessionExerciseEntity(exerciseRequest, session, exercise);
            created.add(sessionExerciseRepository.save(sessionExercise));
        }
        session.getSessionExercises().addAll(created);

        log.info("Added {} exercises to session {}", created.size(), sessionId);
        return workoutPlanMapper.toSessionResponse(session);
    }

    @Override
    @Transactional
    public WorkoutSessionResponse rescheduleSession(Long userId, Long planId, Long sessionId,
                                                    RescheduleWorkoutSessionRequest request) {
        log.info("Rescheduling session {} in plan {} for user: {}", sessionId, planId, userId);
        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        LocalDate currentScheduledDate = session.getScheduledDate();
        if (currentScheduledDate == null) {
            throw new BadRequestException("Session has no scheduled date to reschedule");
        }

        LocalDate today = LocalDate.now();
        if (currentScheduledDate.isBefore(today)) {
            throw new BadRequestException("Cannot reschedule a session that is already in the past. Use missed-workouts flow instead.");
        }

        LocalDate newDate = request.getNewDate();
        if (newDate == null) {
            throw new BadRequestException("New date is required");
        }
        if (newDate.isBefore(today)) {
            throw new BadRequestException("New date must be today or in the future");
        }

        LocalDate planStart = plan.getStartDate();
        if (planStart != null && newDate.isBefore(planStart)) {
            throw new BadRequestException("New date cannot be before plan start date " + planStart);
        }

        // Validate against plan duration window
        if (planStart != null && plan.getDurationWeeks() != null) {
            long totalDays = (long) plan.getDurationWeeks() * 7L;
            LocalDate planEnd = planStart.plusDays(totalDays - 1);
            if (newDate.isAfter(planEnd)) {
                throw new BadRequestException("New date must be within the plan duration window ending on " + planEnd);
            }
        }

        // If the new date is the same as the current date, no-op
        if (newDate.equals(currentScheduledDate)) {
            log.info("Reschedule request for session {} uses the same date {}; no changes applied", sessionId, newDate);
            return workoutPlanMapper.toSessionResponse(session);
        }

        LocalDate originalDate = currentScheduledDate;
        Integer originalDayNumber = session.getDayNumber();

        // When plan has a start date, compute new day number and handle conflicts
        if (planStart != null) {
            long daysBetween = ChronoUnit.DAYS.between(planStart, newDate);
            int newDayNumber = (int) daysBetween + 1;
            if (newDayNumber <= 0) {
                newDayNumber = 1;
            }

            // Find any other sessions already scheduled for the target day
            java.util.List<WorkoutSession> sameDaySessions =
                    workoutSessionRepository.findAllByWorkoutPlanPlanIdAndDayNumber(planId, newDayNumber);
            sameDaySessions.removeIf(s -> s.getSessionId() != null && s.getSessionId().equals(sessionId));

            if (sameDaySessions.isEmpty()) {
                // No conflict: move session directly
                session.setScheduledDate(newDate);
                session.setDayNumber(newDayNumber);
            } else {
                boolean allRestDays = sameDaySessions.stream()
                        .allMatch(s -> Boolean.TRUE.equals(s.getIsRestDay()));

                if (allRestDays && sameDaySessions.size() == 1) {
                    // Swap with existing rest-day session so there is still exactly one session per day
                    WorkoutSession restSession = sameDaySessions.get(0);

                    restSession.setDayNumber(originalDayNumber);
                    restSession.setScheduledDate(originalDate);

                    session.setScheduledDate(newDate);
                    session.setDayNumber(newDayNumber);

                    workoutSessionRepository.save(restSession);
                    log.info("Swapped session {} with rest-day session {} in plan {}", sessionId, restSession.getSessionId(), planId);
                } else {
                    // There is at least one non-rest session already on that day – reject
                    throw new BadRequestException("Target day already has a workout session. Please cancel or reschedule that session first.");
                }
            }
        } else {
            // No plan start date – only move scheduledDate
            session.setScheduledDate(newDate);
        }

        session = workoutSessionRepository.save(session);
        log.info("Rescheduled session {} in plan {} to date {}", sessionId, planId, newDate);
        return workoutPlanMapper.toSessionResponse(session);
    }

    @Override
    @Transactional
    public WorkoutSessionResponse updateSession(Long userId, Long planId, Long sessionId,
                                                UpdateWorkoutSessionRequest request) {
        log.info("Updating session {} in plan {} for user: {}", sessionId, planId, userId);

        workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        workoutPlanMapper.applyPartialUpdate(session, request);

        session = workoutSessionRepository.save(session);
        log.info("Updated session {} in plan {}", sessionId, planId);

        return workoutPlanMapper.toSessionResponse(session);
    }

    @Override
    @Transactional
    public WorkoutSessionResponse updateSessionExercise(Long userId,
                                                        Long planId,
                                                        Long sessionId,
                                                        Long sessionExerciseId,
                                                        UpdateSessionExerciseRequest request) {
        log.info("Updating session exercise {} in session {} of plan {} for user: {}", sessionExerciseId, sessionId, planId, userId);

        workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        SessionExercise sessionExercise = sessionExerciseRepository.findById(sessionExerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("SessionExercise", "id", sessionExerciseId));

        if (sessionExercise.getWorkoutSession() == null ||
                sessionExercise.getWorkoutSession().getSessionId() == null ||
                !sessionExercise.getWorkoutSession().getSessionId().equals(sessionId)) {
            throw new BadRequestException("SessionExercise does not belong to the specified session");
        }

        workoutPlanMapper.applyPartialUpdate(sessionExercise, request, exerciseRepository);

        sessionExerciseRepository.save(sessionExercise);
        log.info("Updated session exercise {} in session {}", sessionExerciseId, sessionId);

        return workoutPlanMapper.toSessionResponse(session);
    }

    @Override
    @Transactional
    public void deleteSessionExercise(Long userId,
                                      Long planId,
                                      Long sessionId,
                                      Long sessionExerciseId) {
        log.info("Deleting session exercise {} from session {} of plan {} for user: {}", sessionExerciseId, sessionId, planId, userId);

        workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        SessionExercise sessionExercise = sessionExerciseRepository.findById(sessionExerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("SessionExercise", "id", sessionExerciseId));

        if (sessionExercise.getWorkoutSession() == null ||
                sessionExercise.getWorkoutSession().getSessionId() == null ||
                !sessionExercise.getWorkoutSession().getSessionId().equals(sessionId)) {
            throw new BadRequestException("SessionExercise does not belong to the specified session");
        }

        sessionExerciseRepository.delete(sessionExercise);
        if (session.getSessionExercises() != null) {
            session.getSessionExercises().removeIf(se -> sessionExerciseId.equals(se.getSessionExerciseId()));
        }

        log.info("Deleted session exercise {} from session {}", sessionExerciseId, sessionId);
    }

    @Override
    @Transactional
    public WorkoutPlanResponse generateAIPlan(Long userId, GenerateAIPlanRequest request) {
        log.info("Generating AI workout plan for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        // Build user profile from onboarding data
        UserProfile profile = userProfileService.buildProfile(userId);

        // Derive goal from onboarding (user.primaryGoal)
        Goal goal = user.getPrimaryGoal();
        if (goal == null) {
            throw new BadRequestException("No primary fitness goal set. Please complete onboarding first.");
        }

        // Derive difficulty from onboarding fitness level (default BEGINNER)
        String difficultyLevel = profile.getFitnessLevel() != null
                ? profile.getFitnessLevel()
                : "BEGINNER";

        // Derive frequency from onboarding schedule days (default 3)
        int frequencyPerWeek = (profile.getScheduleDays() != null && !profile.getScheduleDays().isEmpty())
                ? profile.getScheduleDays().size()
                : 3;

        // Build equipment list from onboarding profile
        List<String> availableEquipment;
        if (profile.getEquipmentKeys() != null && !profile.getEquipmentKeys().isEmpty()) {
            availableEquipment = profile.getEquipmentKeys();
        } else {
            availableEquipment = List.of("Bodyweight only");
        }

        // Build target muscle group names
        List<String> targetMuscleGroupNames = request.getTargetMuscleGroups().stream()
                .map(Enum::name)
                .collect(Collectors.toList());

        // Build AI context
        AiPlanGenerationContext context = AiPlanGenerationContext.builder()
                .profile(profile)
                .availableEquipment(availableEquipment)
                .additionalInformation(request.getAdditionalInformation())
                .frequencyPerWeek(frequencyPerWeek)
                .durationWeeks(request.getDurationWeeks())
                .difficultyLevel(difficultyLevel)
                .startDate(request.getStartDate())
                .goalName(goal.getGoalName())
                .targetMuscleGroups(targetMuscleGroupNames)
                .weekNumber(1)
                .build();

        // Call AI service — structure-only (single-shot, ~75-85% fewer tokens)
        AiStructureResult aiResult = aiService.generateWorkoutStructure(context);

        // Resolve primary muscle group (enum name matches the 'category' column, not 'group_name')
        MuscleGroup muscleGroup = null;
        if (!request.getTargetMuscleGroups().isEmpty()) {
            String category = request.getTargetMuscleGroups().get(0).name();
            muscleGroup = muscleGroupRepository.findFirstByCategory(category)
                    .orElseThrow(() -> new BadRequestException("No MuscleGroup configured for category " + category));
        }

        // Create WorkoutPlan entity from AI result
        WorkoutPlan plan = new WorkoutPlan();
        plan.setUser(user);
        plan.setGoal(goal);
        plan.setPlanName(aiResult.getPlanName() != null ? aiResult.getPlanName() : "AI Generated Plan - " + goal.getGoalName());
        plan.setDescription(aiResult.getDescription() != null ? aiResult.getDescription() : "AI-generated workout plan");
        plan.setMuscleGroup(muscleGroup);
        plan.setFrequencyPerWeek(frequencyPerWeek);
        plan.setDurationWeeks(request.getDurationWeeks());
        plan.setDifficultyLevel(difficultyLevel);
        plan.setStartDate(request.getStartDate());
        plan.setAiGenerated(true);
        plan.setAllowWorkoutSwaps(true);
        plan.setIsActive(true);
        plan.setGenerationStrategy(PlanGenerationStrategy.AI);
        plan.setAlgorithmVersion("AI_V2_STRUCTURE");
        plan.setGeneratedFrom("AI_GENERATE");
        plan.setVersion(1);
        plan.setRecommendationReason(aiResult.getRecommendationReason());

        plan = workoutPlanRepository.save(plan);

        // Track used exercises to avoid duplicates across the plan
        java.util.Set<String> usedExerciseIds = new java.util.HashSet<>();

        // Materialize AI-generated sessions with backend exercise selection
        if (aiResult.getSessions() != null) {
            for (AiSessionStructure sessionStructure : aiResult.getSessions()) {
                WorkoutSession session = new WorkoutSession();
                session.setWorkoutPlan(plan);
                session.setDayNumber(sessionStructure.getDayNumber());
                session.setSessionName(sessionStructure.getSessionName());
                session.setFocusArea(sessionStructure.getFocusArea());
                session.setEstimatedDuration(sessionStructure.getEstimatedDuration());
                session.setIsRestDay(sessionStructure.getIsRestDay() != null ? sessionStructure.getIsRestDay() : false);
                session.setWarmUpNotes(sessionStructure.getWarmUpNotes());
                session.setCoolDownNotes(sessionStructure.getCoolDownNotes());
                if (plan.getStartDate() != null && sessionStructure.getDayNumber() != null) {
                    session.setScheduledDate(plan.getStartDate().plusDays(sessionStructure.getDayNumber() - 1));
                }

                session = workoutSessionRepository.save(session);

                // Fill exercise slots with real exercises from DB
                if (sessionStructure.getExerciseSlots() != null && !Boolean.TRUE.equals(sessionStructure.getIsRestDay())) {
                    for (AiExerciseSlot slot : sessionStructure.getExerciseSlots()) {
                        // Use ExerciseSelector to find the best matching exercise
                        Exercise exercise = exerciseSelector.selectExercise(
                                slot, availableEquipment, difficultyLevel, usedExerciseIds);

                        if (exercise == null) {
                            log.warn("No exercise found for slot: muscleGroup={}, pattern={}. Skipping.",
                                    slot.getMuscleGroup(), slot.getMovementPattern());
                            continue;
                        }

                        usedExerciseIds.add(exercise.getExerciseId());

                        SessionExercise sessionExercise = new SessionExercise();
                        sessionExercise.setWorkoutSession(session);
                        sessionExercise.setExercise(exercise);
                        sessionExercise.setSets(slot.getSets() != null ? slot.getSets() : 3);
                        sessionExercise.setRepetitions(parseRepetitions(slot.getRepetitions()));
                        sessionExercise.setWeightKg(null); // weight determined by user during workout
                        sessionExercise.setRestTimeSeconds(slot.getRestTimeSeconds() != null ? slot.getRestTimeSeconds() : 60);
                        sessionExercise.setOrderIndex(slot.getOrderIndex() != null ? slot.getOrderIndex() : 0);
                        sessionExercise.setNotes(slot.getNotes());
                        sessionExercise.setIsSuperset(false);

                        sessionExerciseRepository.save(sessionExercise);
                        session.getSessionExercises().add(sessionExercise);
                    }
                }

                plan.getWorkoutSessions().add(session);
            }
        }

        log.info("Generated AI workout plan with ID: {} ({} sessions, {} total exercises)", plan.getPlanId(),
                plan.getWorkoutSessions().size(), usedExerciseIds.size());
        return workoutPlanMapper.toResponse(plan);
    }



    /**
     * Parse AI repetitions string (e.g. "10-12", "15", "30 seconds") into Integer.
     * Takes the first number found, defaults to 10.
     */
    private Integer parseRepetitions(String reps) {
        if (reps == null || reps.isBlank()) return 10;
        try {
            // Try direct parse first
            return Integer.parseInt(reps.trim());
        } catch (NumberFormatException e) {
            // Extract first number from strings like "10-12" or "8-10 reps"
            String digits = reps.replaceAll("[^0-9].*", "").trim();
            if (!digits.isEmpty()) {
                try { return Integer.parseInt(digits); } catch (NumberFormatException ignored) {}
            }
            return 10;
        }
    }

    @Override
    @Transactional
    public WorkoutPlanResponse updatePlan(Long userId, Long planId, UpdateWorkoutPlanRequest request) {
        log.info("Updating workout plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        workoutPlanMapper.applyPartialUpdate(plan, request, goalRepository, muscleGroupRepository);

        plan = workoutPlanRepository.save(plan);
        log.info("Updated workout plan: {}", planId);
        return workoutPlanMapper.toResponse(plan);
    }

    @Override
    @Transactional(readOnly = true)
    public WorkoutPlanDetailResponse getPlanById(Long userId, Long planId) {
        log.info("Getting workout plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        return workoutPlanMapper.toDetailResponse(plan);
    }

    @Override
    @Transactional
    public WorkoutPlanResponse togglePlanActive(Long userId, Long planId) {
        log.info("Toggling active status for workout plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        plan.setIsActive(!plan.getIsActive());
        plan = workoutPlanRepository.save(plan);

        log.info("Toggled workout plan {} active status to: {}", planId, plan.getIsActive());
        return workoutPlanMapper.toResponse(plan);
    }

    @Override
    @Transactional
    public void deletePlan(Long userId, Long planId) {
        log.info("Deleting workout plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        workoutPlanRepository.delete(plan);
        log.info("Deleted workout plan: {}", planId);
    }

    @Override
    @Transactional
    public void deleteSession(Long userId, Long planId, Long sessionId) {
        log.info("Deleting session {} from plan {} for user: {}", sessionId, planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        WorkoutSession session = workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(sessionId, planId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionId));

        plan.getWorkoutSessions().remove(session);
        workoutSessionRepository.delete(session);
        log.info("Deleted session {} from plan {}", sessionId, planId);
    }

    @Override
    @Transactional
    public WorkoutPlanResponse duplicatePlan(Long userId, Long planId, String newPlanName) {
        log.info("Duplicating workout plan {} for user: {}", planId, userId);

        WorkoutPlan originalPlan = workoutPlanRepository.findByIdWithSessionsAndExercises(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        // Create new plan as a copy
        WorkoutPlan newPlan = new WorkoutPlan();
        newPlan.setUser(user);
        newPlan.setGoal(originalPlan.getGoal());
        newPlan.setPlanName(newPlanName != null ? newPlanName : originalPlan.getPlanName() + " (Copy)");
        newPlan.setDescription(originalPlan.getDescription());
        newPlan.setMuscleGroup(originalPlan.getMuscleGroup());
        newPlan.setFrequencyPerWeek(originalPlan.getFrequencyPerWeek());
        newPlan.setDurationWeeks(originalPlan.getDurationWeeks());
        newPlan.setDifficultyLevel(originalPlan.getDifficultyLevel());
        newPlan.setStartDate(originalPlan.getStartDate());
        newPlan.setAiGenerated(false); // Duplicated plans are not AI-generated
        newPlan.setAllowWorkoutSwaps(originalPlan.getAllowWorkoutSwaps());
        newPlan.setIsActive(true);

        newPlan = workoutPlanRepository.save(newPlan);

        // Duplicate sessions and exercises
        if (originalPlan.getWorkoutSessions() != null) {
            // Create temporary sorted list for duplication
            List<WorkoutSession> sortedSessions = originalPlan.getWorkoutSessions().stream()
                    .sorted(Comparator.comparing(WorkoutSession::getDayNumber))
                    .collect(Collectors.toList());
            
            List<WorkoutSession> newSessions = new ArrayList<>();
            for (WorkoutSession originalSession : sortedSessions) {
                WorkoutSession newSession = new WorkoutSession();
                newSession.setWorkoutPlan(newPlan);
                newSession.setSessionName(originalSession.getSessionName());
                newSession.setDayNumber(originalSession.getDayNumber());
                newSession.setFocusArea(originalSession.getFocusArea());
                newSession.setEstimatedDuration(originalSession.getEstimatedDuration());
                newSession.setWarmUpNotes(originalSession.getWarmUpNotes());
                newSession.setCoolDownNotes(originalSession.getCoolDownNotes());
                newSession.setIsRestDay(originalSession.getIsRestDay());
                newSession.setScheduledDate(originalSession.getScheduledDate());

                newSession = workoutSessionRepository.save(newSession);

                // Duplicate session exercises
                if (originalSession.getSessionExercises() != null) {
                    List<SessionExercise> newExercises = new ArrayList<>();
                    for (SessionExercise originalExercise : originalSession.getSessionExercises()) {
                        SessionExercise newExercise = new SessionExercise();
                        newExercise.setWorkoutSession(newSession);
                        newExercise.setExercise(originalExercise.getExercise());
                        newExercise.setSets(originalExercise.getSets());
                        newExercise.setRepetitions(originalExercise.getRepetitions());
                        newExercise.setWeightKg(originalExercise.getWeightKg());
                        newExercise.setRestTimeSeconds(originalExercise.getRestTimeSeconds());
                        newExercise.setOrderIndex(originalExercise.getOrderIndex());
                        newExercise.setNotes(originalExercise.getNotes());
                        newExercise.setIsSuperset(originalExercise.getIsSuperset());

                        newExercises.add(sessionExerciseRepository.save(newExercise));
                    }
                    newSession.getSessionExercises().addAll(newExercises);
                }
                newSessions.add(newSession);
            }
            newPlan.getWorkoutSessions().addAll(newSessions);
        }

        log.info("Duplicated workout plan {} as new plan: {}", planId, newPlan.getPlanId());
        return workoutPlanMapper.toResponse(newPlan);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WorkoutPlanSummaryResponse> getUserPlans(Long userId, Boolean activeOnly, Pageable pageable) {
        log.info("Getting workout plans for user: {} (activeOnly={})", userId, activeOnly);
        if (Boolean.TRUE.equals(activeOnly)) {
            return workoutPlanRepository.findByUserUserIdAndIsActiveTrue(userId, pageable)
                    .map(workoutPlanMapper::toSummaryResponse);
        }
        return workoutPlanRepository.findByUserUserId(userId, pageable)
                .map(workoutPlanMapper::toSummaryResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WorkoutPlanSummaryResponse> filterPlans(Long userId, WorkoutPlanFilterRequest filter, Pageable pageable) {
        log.info("Filtering workout plans for user: {} with filter: {}", userId, filter);

        org.springframework.data.jpa.domain.Specification<WorkoutPlan> spec = (root, query, cb) -> {
            java.util.List<jakarta.persistence.criteria.Predicate> predicates = new java.util.ArrayList<>();

            // Always filter by user
            predicates.add(cb.equal(root.get("user").get("userId"), userId));

            if (filter.getIsActive() != null) {
                predicates.add(cb.equal(root.get("isActive"), filter.getIsActive()));
            }

            if (filter.getGoalId() != null) {
                predicates.add(cb.equal(root.get("goal").get("goalId"), filter.getGoalId()));
            }

            if (filter.getMuscleGroupId() != null) {
                predicates.add(cb.equal(root.get("muscleGroup").get("muscleGroupId"), filter.getMuscleGroupId()));
            }

            if (filter.getAiGenerated() != null) {
                predicates.add(cb.equal(root.get("aiGenerated"), filter.getAiGenerated()));
            }

            if (filter.getCreatedAfter() != null) {
                predicates.add(cb.greaterThanOrEqualTo(
                        root.get("createdAt"), 
                        filter.getCreatedAfter().atStartOfDay(java.time.ZoneId.systemDefault()).toInstant()));
            }

            if (filter.getCreatedBefore() != null) {
                predicates.add(cb.lessThanOrEqualTo(
                        root.get("createdAt"), 
                        filter.getCreatedBefore().plusDays(1).atStartOfDay(java.time.ZoneId.systemDefault()).toInstant()));
            }

            if (filter.getSearchQuery() != null && !filter.getSearchQuery().isBlank()) {
                String searchPattern = "%" + filter.getSearchQuery().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("planName")), searchPattern),
                        cb.like(cb.lower(root.get("description")), searchPattern)
                ));
            }

            return cb.and(predicates.toArray(new jakarta.persistence.criteria.Predicate[0]));
        };

        return workoutPlanRepository.findAll(spec, pageable)
                .map(workoutPlanMapper::toSummaryResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public WorkoutPlanStatsResponse getPlanStats(Long userId) {
        log.info("Getting workout plan stats for user: {}", userId);

        long totalPlans = workoutPlanRepository.countByUserId(userId);
        long activePlans = workoutPlanRepository.countActivePlansByUserId(userId);
        long completedWorkouts = workoutSessionLogRepository.countTotalByUserId(userId);

        // Calculate current streak from session logs
        int currentStreak = calculateCurrentStreak(userId);

        return WorkoutPlanStatsResponse.builder()
                .totalPlans(totalPlans)
                .activePlans(activePlans)
                .completedWorkouts(completedWorkouts)
                .currentStreak(currentStreak)
                .build();
    }

    /**
     * Calculate the current consecutive-day workout streak for a user.
     * Counts backward from today/yesterday checking if a session log exists for each date.
     */
    private int calculateCurrentStreak(Long userId) {
        List<WorkoutSessionLog> logs = workoutSessionLogRepository
                .findByUserUserIdOrderByPerformedAtDesc(userId);
        if (logs.isEmpty()) return 0;

        java.util.Set<LocalDate> workoutDates = logs.stream()
                .map(log1 -> log1.getPerformedAt()
                        .atZone(java.time.ZoneId.systemDefault())
                        .toLocalDate())
                .collect(java.util.stream.Collectors.toSet());

        LocalDate checkDate = LocalDate.now();
        // Allow streak to start from yesterday if no workout today
        if (!workoutDates.contains(checkDate)) {
            checkDate = checkDate.minusDays(1);
        }

        int streak = 0;
        while (workoutDates.contains(checkDate)) {
            streak++;
            checkDate = checkDate.minusDays(1);
        }
        return streak;
    }
}

