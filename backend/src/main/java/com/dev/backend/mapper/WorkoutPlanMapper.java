package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateSessionExerciseRequest;
import com.dev.backend.model.dto.request.CreateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.CreateWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutSessionRequest;
import com.dev.backend.model.enums.PlanGenerationStrategy;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.MuscleGroupRepository;
import com.dev.backend.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class WorkoutPlanMapper {

    private final ExerciseMapper exerciseMapper;

    public WorkoutPlan toEntity(CreateWorkoutPlanRequest request, User user, Goal goal, MuscleGroup muscleGroup) {
        WorkoutPlan plan = new WorkoutPlan();
        plan.setUser(user);
        plan.setGoal(goal);
        plan.setMuscleGroup(muscleGroup);
        plan.setPlanName(request.getPlanName());
        plan.setDescription(request.getDescription());
        plan.setFrequencyPerWeek(request.getFrequencyPerWeek());
        plan.setDurationWeeks(request.getDurationWeeks());
        plan.setDifficultyLevel(request.getDifficultyLevel().name());
        plan.setStartDate(request.getStartDate());
        plan.setAiGenerated(false);
        plan.setAllowWorkoutSwaps(request.getAllowWorkoutSwaps() != null ? request.getAllowWorkoutSwaps() : true);
        plan.setIsActive(true);
        plan.setGenerationStrategy(PlanGenerationStrategy.MANUAL);
        if (request.getWorkoutDates() != null && !request.getWorkoutDates().isEmpty()) {
            plan.setScheduledWorkoutDates(new ArrayList<>(request.getWorkoutDates()));
        }
        return plan;
    }

    public WorkoutSession toSessionEntity(CreateWorkoutSessionRequest request, WorkoutPlan plan) {
        WorkoutSession session = new WorkoutSession();
        session.setWorkoutPlan(plan);
        session.setSessionName(request.getSessionName());
        session.setDayNumber(request.getDayNumber());
        session.setFocusArea(request.getFocusArea());
        session.setEstimatedDuration(request.getEstimatedDuration());
        session.setWarmUpNotes(request.getWarmUpNotes());
        session.setCoolDownNotes(request.getCoolDownNotes());
        session.setIsRestDay(request.getIsRestDay() != null ? request.getIsRestDay() : false);
        return session;
    }

    public SessionExercise toSessionExerciseEntity(CreateSessionExerciseRequest request, 
                                                    WorkoutSession session, 
                                                    Exercise exercise) {
        SessionExercise sessionExercise = new SessionExercise();
        sessionExercise.setWorkoutSession(session);
        sessionExercise.setExercise(exercise);
        sessionExercise.setSets(request.getSets());
        sessionExercise.setRepetitions(request.getRepetitions());
        sessionExercise.setWeightKg(request.getWeightKg());
        sessionExercise.setRestTimeSeconds(request.getRestTimeSeconds());
        sessionExercise.setOrderIndex(request.getOrderIndex());
        sessionExercise.setNotes(request.getNotes());
        sessionExercise.setIsSuperset(request.getIsSuperset() != null ? request.getIsSuperset() : false);
        return sessionExercise;
    }

    // ── Partial-update helpers (single source of truth) ──────────────────────

    /**
     * Apply non-null fields from the update request to the plan entity.
     * Resolves Goal and MuscleGroup via repositories when their IDs are provided.
     */
    public void applyPartialUpdate(WorkoutPlan plan,
                                   UpdateWorkoutPlanRequest request,
                                   GoalRepository goalRepository,
                                   MuscleGroupRepository muscleGroupRepository) {
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
    }

    /**
     * Apply non-null fields from the update request to the session entity.
     */
    public void applyPartialUpdate(WorkoutSession session, UpdateWorkoutSessionRequest request) {
        if (request.getSessionName() != null) {
            session.setSessionName(request.getSessionName());
        }
        if (request.getDayNumber() != null) {
            session.setDayNumber(request.getDayNumber());
        }
        if (request.getFocusArea() != null) {
            session.setFocusArea(request.getFocusArea());
        }
        if (request.getEstimatedDuration() != null) {
            session.setEstimatedDuration(request.getEstimatedDuration());
        }
        if (request.getWarmUpNotes() != null) {
            session.setWarmUpNotes(request.getWarmUpNotes());
        }
        if (request.getCoolDownNotes() != null) {
            session.setCoolDownNotes(request.getCoolDownNotes());
        }
        if (request.getIsRestDay() != null) {
            session.setIsRestDay(request.getIsRestDay());
        }
    }

    /**
     * Apply non-null fields from the update request to the session exercise entity.
     * Resolves Exercise via repository when exerciseId is provided.
     */
    public void applyPartialUpdate(SessionExercise sessionExercise,
                                   UpdateSessionExerciseRequest request,
                                   ExerciseRepository exerciseRepository) {
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
    }

    public WorkoutPlanResponse toResponse(WorkoutPlan plan) {
        return WorkoutPlanResponse.builder()
                .planId(plan.getPlanId())
                .planName(plan.getPlanName())
                .description(plan.getDescription())
                .goal(toGoalResponse(plan.getGoal()))
                .muscleGroup(exerciseMapper.toMuscleGroupResponse(plan.getMuscleGroup()))
                .frequencyPerWeek(plan.getFrequencyPerWeek())
                .durationWeeks(plan.getDurationWeeks())
                .difficultyLevel(com.dev.backend.model.enums.DifficultyLevel.valueOf(plan.getDifficultyLevel()))
                .startDate(plan.getStartDate())
                .scheduledWorkoutDates(plan.getScheduledWorkoutDates() != null ? new ArrayList<>(plan.getScheduledWorkoutDates()) : null)
                .algorithmVersion(plan.getAlgorithmVersion())
                .generatedFrom(plan.getGeneratedFrom())
                .version(plan.getVersion())
                .recommendationReason(plan.getRecommendationReason())
                .aiGenerated(plan.getAiGenerated())
                .allowWorkoutSwaps(plan.getAllowWorkoutSwaps())
                .isActive(plan.getIsActive())
                .createdAt(plan.getCreatedAt())
                .updatedAt(plan.getUpdatedAt())
                .sessions(toSessionResponseList(plan.getWorkoutSessions()))
                .build();
    }

    public WorkoutPlanSummaryResponse toSummaryResponse(WorkoutPlan plan) {
        return WorkoutPlanSummaryResponse.builder()
                .planId(plan.getPlanId())
                .planName(plan.getPlanName())
                .description(plan.getDescription())
                .goalName(plan.getGoal() != null ? plan.getGoal().getGoalName() : null)
                .muscleGroup(exerciseMapper.toMuscleGroupResponse(plan.getMuscleGroup()))
                .frequencyPerWeek(plan.getFrequencyPerWeek())
                .durationWeeks(plan.getDurationWeeks())
                .difficultyLevel(com.dev.backend.model.enums.DifficultyLevel.valueOf(plan.getDifficultyLevel()))
                .startDate(plan.getStartDate())
                .aiGenerated(plan.getAiGenerated())
                .isActive(plan.getIsActive())
                .sessionCount(plan.getWorkoutSessions() != null ? plan.getWorkoutSessions().size() : 0)
                .createdAt(plan.getCreatedAt())
                .build();
    }

    public GoalResponse toGoalResponse(Goal goal) {
        if (goal == null) return null;
        return GoalResponse.builder()
                .goalId(goal.getGoalId())
                .goalName(goal.getGoalName())
                .description(goal.getDescription())
                .recommendedRepRange(goal.getRecommendedRepRange())
                .recommendedRestTime(goal.getRecommendedRestTime())
                .recommendedFrequency(goal.getRecommendedFrequency())
                .targetCalorieAdjustment(goal.getTargetCalorieAdjustment())
                .build();
    }

    public List<WorkoutSessionResponse> toSessionResponseList(Set<WorkoutSession> sessions) {
        if (sessions == null || sessions.isEmpty()) return Collections.emptyList();
        return sessions.stream()
                .sorted(Comparator.comparing(WorkoutSession::getDayNumber))
                .map(this::toSessionResponse)
                .collect(Collectors.toList());
    }

    public WorkoutSessionResponse toSessionResponse(WorkoutSession session) {
        return toSessionResponse(session, false, null);
    }

    public WorkoutSessionResponse toSessionResponse(WorkoutSession session, Boolean isCompleted) {
        return toSessionResponse(session, isCompleted, null);
    }

    public WorkoutSessionResponse toSessionResponse(WorkoutSession session, Boolean isCompleted, Long missedWorkoutId) {
        return WorkoutSessionResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .dayNumber(session.getDayNumber())
                .scheduledDate(session.getScheduledDate())
                .focusArea(session.getFocusArea())
                .estimatedDuration(session.getEstimatedDuration())
                .warmUpNotes(session.getWarmUpNotes())
                .coolDownNotes(session.getCoolDownNotes())
                .isRestDay(session.getIsRestDay())
                .isCompleted(isCompleted)
                .missedWorkoutId(missedWorkoutId)
                .isMissed(missedWorkoutId != null)
                .exercises(toSessionExerciseResponseList(session.getSessionExercises()))
                .build();
    }

    public List<SessionExerciseResponse> toSessionExerciseResponseList(List<SessionExercise> exercises) {
        if (exercises == null || exercises.isEmpty()) return Collections.emptyList();
        return exercises.stream()
                .sorted(Comparator.comparing(SessionExercise::getOrderIndex))
                .map(this::toSessionExerciseResponse)
                .collect(Collectors.toList());
    }

    public SessionExerciseResponse toSessionExerciseResponse(SessionExercise se) {
        List<EquipmentResponse> equipment = Collections.emptyList();
        if (se.getExercise() != null && se.getExercise().getExerciseEquipments() != null) {
            equipment = se.getExercise().getExerciseEquipments().stream()
                    .map(ee -> exerciseMapper.toEquipmentResponse(ee.getEquipment()))
                    .collect(Collectors.toList());
        }
        
        return SessionExerciseResponse.builder()
                .sessionExerciseId(se.getSessionExerciseId())
                .exercise(toExerciseSummary(se.getExercise()))
                .sets(se.getSets())
                .repetitions(se.getRepetitions())
                .weightKg(se.getWeightKg())
                .restTimeSeconds(se.getRestTimeSeconds())
                .orderIndex(se.getOrderIndex())
                .notes(se.getNotes())
                .isSuperset(se.getIsSuperset())
                .equipmentUsed(equipment)
                .build();
    }

    public ExerciseSummaryResponse toExerciseSummary(Exercise exercise) {
        if (exercise == null) return null;
        return ExerciseSummaryResponse.builder()
                .exerciseId(exercise.getExerciseId())
                .exerciseName(exercise.getExerciseName())
                .description(exercise.getDescription())
                .difficultyLevel(exercise.getDifficultyLevel())
                .exerciseType(exercise.getExerciseType())
                .imageUrl(exercise.getImageUrl())
                .caloriesBurnedPerMin(exercise.getCaloriesBurnedPerMin())
                .build();
    }

    public WorkoutPlanDetailResponse toDetailResponse(WorkoutPlan plan) {
        return WorkoutPlanDetailResponse.builder()
                .planId(plan.getPlanId())
                .planName(plan.getPlanName())
                .description(plan.getDescription())
                .goal(toGoalResponse(plan.getGoal()))
                .muscleGroup(exerciseMapper.toMuscleGroupResponse(plan.getMuscleGroup()))
                .frequencyPerWeek(plan.getFrequencyPerWeek())
                .durationWeeks(plan.getDurationWeeks())
                .difficultyLevel(com.dev.backend.model.enums.DifficultyLevel.valueOf(plan.getDifficultyLevel()))
                .startDate(plan.getStartDate())
                .endDate(plan.getStartDate().plusWeeks(plan.getDurationWeeks()).minusDays(1))
                .scheduledWorkoutDates(plan.getScheduledWorkoutDates() != null ? new ArrayList<>(plan.getScheduledWorkoutDates()) : null)
                .algorithmVersion(plan.getAlgorithmVersion())
                .generatedFrom(plan.getGeneratedFrom())
                .version(plan.getVersion())
                .recommendationReason(plan.getRecommendationReason())
                .aiGenerated(plan.getAiGenerated())
                .allowWorkoutSwaps(plan.getAllowWorkoutSwaps())
                .isActive(plan.getIsActive())
                .createdAt(plan.getCreatedAt())
                .updatedAt(plan.getUpdatedAt())
                .build();
    }

    public WorkoutPlanSummaryWithSessionsResponse toSummaryWithSessionsResponse(WorkoutPlan plan) {
        return WorkoutPlanSummaryWithSessionsResponse.builder()
                .planId(plan.getPlanId())
                .planName(plan.getPlanName())
                .description(plan.getDescription())
                .goal(toGoalResponse(plan.getGoal()))
                .muscleGroup(exerciseMapper.toMuscleGroupResponse(plan.getMuscleGroup()))
                .frequencyPerWeek(plan.getFrequencyPerWeek())
                .durationWeeks(plan.getDurationWeeks())
                .difficultyLevel(com.dev.backend.model.enums.DifficultyLevel.valueOf(plan.getDifficultyLevel()))
                .startDate(plan.getStartDate())
                .algorithmVersion(plan.getAlgorithmVersion())
                .generatedFrom(plan.getGeneratedFrom())
                .version(plan.getVersion())
                .recommendationReason(plan.getRecommendationReason())
                .aiGenerated(plan.getAiGenerated())
                .allowWorkoutSwaps(plan.getAllowWorkoutSwaps())
                .isActive(plan.getIsActive())
                .createdAt(plan.getCreatedAt())
                .updatedAt(plan.getUpdatedAt())
                .sessions(toSessionSummaryResponseList(plan.getWorkoutSessions()))
                .build();
    }

    public List<WorkoutSessionSummaryResponse> toSessionSummaryResponseList(Set<WorkoutSession> sessions) {
        if (sessions == null || sessions.isEmpty()) return Collections.emptyList();
        return sessions.stream()
                .sorted(Comparator.comparing(WorkoutSession::getDayNumber))
                .map(this::toSessionSummaryResponse)
                .collect(Collectors.toList());
    }

    public WorkoutSessionSummaryResponse toSessionSummaryResponse(WorkoutSession session) {
        int exerciseCount = session.getSessionExercises() != null ? session.getSessionExercises().size() : 0;
        return WorkoutSessionSummaryResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .dayNumber(session.getDayNumber())
                .scheduledDate(session.getScheduledDate())
                .focusArea(session.getFocusArea())
                .estimatedDuration(session.getEstimatedDuration())
                .warmUpNotes(session.getWarmUpNotes())
                .coolDownNotes(session.getCoolDownNotes())
                .isRestDay(session.getIsRestDay())
                .exerciseCount(exerciseCount)
                .build();
    }
}
