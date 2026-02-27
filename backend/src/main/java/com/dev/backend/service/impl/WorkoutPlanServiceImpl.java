package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.WorkoutPlanDetailResponse;
import com.dev.backend.model.dto.response.WorkoutPlanResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryResponse;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.repository.*;
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

    public WorkoutPlanServiceImpl(WorkoutPlanRepository workoutPlanRepository,
                                  WorkoutSessionRepository workoutSessionRepository,
                                  SessionExerciseRepository sessionExerciseRepository,
                                  GoalRepository goalRepository,
                                  ExerciseRepository exerciseRepository,
                                  UserRepository userRepository,
                                  MuscleGroupRepository muscleGroupRepository,
                                  WorkoutPlanMapper workoutPlanMapper,
                                  WorkoutDateCalculator workoutDateCalculator) {
        this.workoutPlanRepository = workoutPlanRepository;
        this.workoutSessionRepository = workoutSessionRepository;
        this.sessionExerciseRepository = sessionExerciseRepository;
        this.goalRepository = goalRepository;
        this.exerciseRepository = exerciseRepository;
        this.userRepository = userRepository;
        this.muscleGroupRepository = muscleGroupRepository;
        this.workoutPlanMapper = workoutPlanMapper;
        this.workoutDateCalculator = workoutDateCalculator;
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

        if (request.getExerciseId() != null) {
            Exercise exercise = exerciseRepository.findById(request.getExerciseId())
                    .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", request.getExerciseId()));
            sessionExercise.setExercise(exercise);
        }
        if (request.getSets() != null) {
            sessionExercise.setSets(request.getSets());
        }
        if (request.getRepetitions() != null) {
            sessionExercise.setRepetitions(request.getRepetitions());
        }
        if (request.getWeightKg() != null) {
            sessionExercise.setWeightKg(request.getWeightKg());
        }
        if (request.getRestTimeSeconds() != null) {
            sessionExercise.setRestTimeSeconds(request.getRestTimeSeconds());
        }
        if (request.getOrderIndex() != null) {
            sessionExercise.setOrderIndex(request.getOrderIndex());
        }
        if (request.getNotes() != null) {
            sessionExercise.setNotes(request.getNotes());
        }
        if (request.getIsSuperset() != null) {
            sessionExercise.setIsSuperset(request.getIsSuperset());
        }

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

        Goal goal = goalRepository.findById(request.getGoalId())
                .orElseThrow(() -> new ResourceNotFoundException("Goal", "id", request.getGoalId()));

        // TODO: Implement AI logic to generate optimal workout plan
        // For now, create a basic plan structure
        WorkoutPlan plan = new WorkoutPlan();
        plan.setUser(user);
        plan.setGoal(goal);
        plan.setPlanName("AI Generated Plan - " + goal.getGoalName());
        plan.setDescription("AI-generated workout plan optimized for " + goal.getGoalName());
        if (request.getTargetMuscleGroups() != null && !request.getTargetMuscleGroups().isEmpty()) {
            String groupName = request.getTargetMuscleGroups().get(0).name();
            MuscleGroup muscleGroup = muscleGroupRepository.findByGroupName(groupName)
                    .orElseThrow(() -> new BadRequestException("No MuscleGroup configured for target " + groupName));
            plan.setMuscleGroup(muscleGroup);
        }
        plan.setFrequencyPerWeek(request.getFrequencyPerWeek());
        plan.setDurationWeeks(request.getDurationWeeks());
        plan.setDifficultyLevel(request.getDifficultyLevel().name());
        plan.setStartDate(request.getStartDate());
        plan.setAiGenerated(true);
        plan.setAllowWorkoutSwaps(true);
        plan.setIsActive(true);

        plan = workoutPlanRepository.save(plan);

        // TODO: Add AI-generated sessions and exercises based on:
        // - User's fitness level
        // - Available equipment
        // - Target muscle groups
        // - Progressive overload structure

        log.info("Generated AI workout plan with ID: {}", plan.getPlanId());
        return workoutPlanMapper.toResponse(plan);
    }

    @Override
    @Transactional
    public WorkoutPlanResponse updatePlan(Long userId, Long planId, UpdateWorkoutPlanRequest request) {
        log.info("Updating workout plan {} for user: {}", planId, userId);

        WorkoutPlan plan = workoutPlanRepository.findByPlanIdAndUserUserId(planId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", planId));

        // Update basic fields if provided
        if (request.getPlanName() != null) {
            plan.setPlanName(request.getPlanName());
        }
        if (request.getDescription() != null) {
            plan.setDescription(request.getDescription());
        }
        if (request.getGoalId() != null) {
            Goal goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal", "id", request.getGoalId()));
            plan.setGoal(goal);
        }
        if (request.getMuscleGroupId() != null) {
            MuscleGroup muscleGroup = muscleGroupRepository.findById(request.getMuscleGroupId())
                    .orElseThrow(() -> new ResourceNotFoundException("MuscleGroup", "id", request.getMuscleGroupId()));
            plan.setMuscleGroup(muscleGroup);
        }
        if (request.getFrequencyPerWeek() != null) {
            plan.setFrequencyPerWeek(request.getFrequencyPerWeek());
        }
        if (request.getDurationWeeks() != null) {
            plan.setDurationWeeks(request.getDurationWeeks());
        }
        if (request.getDifficultyLevel() != null) {
            plan.setDifficultyLevel(request.getDifficultyLevel().name());
        }
        if (request.getAllowWorkoutSwaps() != null) {
            plan.setAllowWorkoutSwaps(request.getAllowWorkoutSwaps());
        }
        if (request.getWorkoutDates() != null) {
            plan.getScheduledWorkoutDates().clear();
            plan.getScheduledWorkoutDates().addAll(request.getWorkoutDates());
        }

        // Update sessions if provided
        if (request.getSessions() != null) {
            updateSessions(plan, request.getSessions());
        }

        plan = workoutPlanRepository.save(plan);
        log.info("Updated workout plan: {}", planId);
        return workoutPlanMapper.toResponse(plan);
    }

    private void updateSessions(WorkoutPlan plan, List<UpdateWorkoutSessionRequest> sessionRequests) {
        for (UpdateWorkoutSessionRequest sessionRequest : sessionRequests) {
            WorkoutSession session;
            
            if (sessionRequest.getSessionId() != null) {
                // Update existing session
                session = workoutSessionRepository.findById(sessionRequest.getSessionId())
                        .orElseThrow(() -> new ResourceNotFoundException("WorkoutSession", "id", sessionRequest.getSessionId()));
                
                if (sessionRequest.getSessionName() != null) {
                    session.setSessionName(sessionRequest.getSessionName());
                }
                if (sessionRequest.getDayNumber() != null) {
                    session.setDayNumber(sessionRequest.getDayNumber());
                }
                if (sessionRequest.getFocusArea() != null) {
                    session.setFocusArea(sessionRequest.getFocusArea());
                }
                if (sessionRequest.getEstimatedDuration() != null) {
                    session.setEstimatedDuration(sessionRequest.getEstimatedDuration());
                }
                if (sessionRequest.getWarmUpNotes() != null) {
                    session.setWarmUpNotes(sessionRequest.getWarmUpNotes());
                }
                if (sessionRequest.getCoolDownNotes() != null) {
                    session.setCoolDownNotes(sessionRequest.getCoolDownNotes());
                }
                if (sessionRequest.getIsRestDay() != null) {
                    session.setIsRestDay(sessionRequest.getIsRestDay());
                }
            } else {
                // Create new session
                session = new WorkoutSession();
                session.setWorkoutPlan(plan);
                session.setSessionName(sessionRequest.getSessionName());
                session.setDayNumber(sessionRequest.getDayNumber());
                session.setFocusArea(sessionRequest.getFocusArea());
                session.setEstimatedDuration(sessionRequest.getEstimatedDuration());
                session.setWarmUpNotes(sessionRequest.getWarmUpNotes());
                session.setCoolDownNotes(sessionRequest.getCoolDownNotes());
                session.setIsRestDay(sessionRequest.getIsRestDay() != null ? sessionRequest.getIsRestDay() : false);
            }
            
            workoutSessionRepository.save(session);

            // Update exercises if provided
            if (sessionRequest.getExercises() != null) {
                updateSessionExercises(session, sessionRequest.getExercises());
            }
        }
    }

    private void updateSessionExercises(WorkoutSession session, List<UpdateSessionExerciseRequest> exerciseRequests) {
        for (UpdateSessionExerciseRequest exerciseRequest : exerciseRequests) {
            SessionExercise sessionExercise;
            
            if (exerciseRequest.getSessionExerciseId() != null) {
                // Update existing exercise
                sessionExercise = sessionExerciseRepository.findById(exerciseRequest.getSessionExerciseId())
                        .orElseThrow(() -> new ResourceNotFoundException("SessionExercise", "id", exerciseRequest.getSessionExerciseId()));
                
                if (exerciseRequest.getExerciseId() != null) {
                    Exercise exercise = exerciseRepository.findById(exerciseRequest.getExerciseId())
                            .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseRequest.getExerciseId()));
                    sessionExercise.setExercise(exercise);
                }
                if (exerciseRequest.getSets() != null) {
                    sessionExercise.setSets(exerciseRequest.getSets());
                }
                if (exerciseRequest.getRepetitions() != null) {
                    sessionExercise.setRepetitions(exerciseRequest.getRepetitions());
                }
                if (exerciseRequest.getWeightKg() != null) {
                    sessionExercise.setWeightKg(exerciseRequest.getWeightKg());
                }
                if (exerciseRequest.getRestTimeSeconds() != null) {
                    sessionExercise.setRestTimeSeconds(exerciseRequest.getRestTimeSeconds());
                }
                if (exerciseRequest.getOrderIndex() != null) {
                    sessionExercise.setOrderIndex(exerciseRequest.getOrderIndex());
                }
                if (exerciseRequest.getNotes() != null) {
                    sessionExercise.setNotes(exerciseRequest.getNotes());
                }
                if (exerciseRequest.getIsSuperset() != null) {
                    sessionExercise.setIsSuperset(exerciseRequest.getIsSuperset());
                }
            } else {
                // Create new session exercise
                if (exerciseRequest.getExerciseId() == null) {
                    throw new BadRequestException("Exercise ID is required for new session exercises");
                }
                Exercise exercise = exerciseRepository.findById(exerciseRequest.getExerciseId())
                        .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseRequest.getExerciseId()));

                sessionExercise = new SessionExercise();
                sessionExercise.setWorkoutSession(session);
                sessionExercise.setExercise(exercise);
                sessionExercise.setSets(exerciseRequest.getSets());
                sessionExercise.setRepetitions(exerciseRequest.getRepetitions());
                sessionExercise.setWeightKg(exerciseRequest.getWeightKg());
                sessionExercise.setRestTimeSeconds(exerciseRequest.getRestTimeSeconds());
                sessionExercise.setOrderIndex(exerciseRequest.getOrderIndex());
                sessionExercise.setNotes(exerciseRequest.getNotes());
                sessionExercise.setIsSuperset(exerciseRequest.getIsSuperset() != null ? exerciseRequest.getIsSuperset() : false);
            }
            
            sessionExerciseRepository.save(sessionExercise);
        }
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
}

