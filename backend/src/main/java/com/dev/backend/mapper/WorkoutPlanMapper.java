package com.dev.backend.mapper;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.request.CreateSessionExerciseRequest;
import com.dev.backend.model.dto.request.CreateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.CreateWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutPlanRequest;
import com.dev.backend.model.dto.request.UpdateWorkoutSessionRequest;
import com.dev.backend.model.dto.response.EquipmentResponse;
import com.dev.backend.model.dto.response.ExerciseSummaryResponse;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.dto.response.MuscleGroupResponse;
import com.dev.backend.model.dto.response.SessionExerciseResponse;
import com.dev.backend.model.dto.response.WorkoutPlanDetailResponse;
import com.dev.backend.model.dto.response.WorkoutPlanResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryResponse;
import com.dev.backend.model.dto.response.WorkoutPlanSummaryWithSessionsResponse;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.dto.response.WorkoutSessionSummaryResponse;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.MuscleGroup;
import com.dev.backend.model.entity.SessionExercise;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.model.entity.WorkoutSession;
import com.dev.backend.model.enums.DifficultyLevel;
import com.dev.backend.model.enums.PlanGenerationStrategy;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.MuscleGroupRepository;
import org.mapstruct.BeanMapping;
import org.mapstruct.InjectionStrategy;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(
        componentModel = "spring",
        uses = {ExerciseMapper.class},
        injectionStrategy = InjectionStrategy.CONSTRUCTOR,
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        imports = {DifficultyLevel.class, PlanGenerationStrategy.class, ArrayList.class}
)
public interface WorkoutPlanMapper extends BaseMapper<WorkoutPlan, CreateWorkoutPlanRequest, WorkoutPlanResponse> {

    @Override
    @Mapping(target = "difficultyLevel", expression = "java(request.getDifficultyLevel() != null ? request.getDifficultyLevel().name() : null)")
    @Mapping(target = "aiGenerated", constant = "false")
    @Mapping(target = "allowWorkoutSwaps", expression = "java(request.getAllowWorkoutSwaps() != null ? request.getAllowWorkoutSwaps() : true)")
    @Mapping(target = "isActive", constant = "true")
    @Mapping(target = "generationStrategy", expression = "java(PlanGenerationStrategy.MANUAL)")
    @Mapping(target = "scheduledWorkoutDates", expression = "java(request.getWorkoutDates() != null && !request.getWorkoutDates().isEmpty() ? new ArrayList<>(request.getWorkoutDates()) : new ArrayList<>())")
    WorkoutPlan toEntity(CreateWorkoutPlanRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "difficultyLevel", expression = "java(request.getDifficultyLevel() != null ? request.getDifficultyLevel().name() : entity.getDifficultyLevel())")
    void updateEntityFromRequest(@MappingTarget WorkoutPlan entity, CreateWorkoutPlanRequest request);

    default WorkoutPlan toEntity(CreateWorkoutPlanRequest request, User user, Goal goal, MuscleGroup muscleGroup) {
        WorkoutPlan plan = toEntity(request);
        if (plan != null) {
            plan.setUser(user);
            plan.setGoal(goal);
            plan.setMuscleGroup(muscleGroup);
        }
        return plan;
    }

    @Mapping(target = "workoutPlan", source = "plan")
    @Mapping(target = "sessionName", source = "request.sessionName")
    @Mapping(target = "dayNumber", source = "request.dayNumber")
    @Mapping(target = "focusArea", source = "request.focusArea")
    @Mapping(target = "estimatedDuration", source = "request.estimatedDuration")
    @Mapping(target = "warmUpNotes", source = "request.warmUpNotes")
    @Mapping(target = "coolDownNotes", source = "request.coolDownNotes")
    @Mapping(target = "isRestDay", expression = "java(request.getIsRestDay() != null ? request.getIsRestDay() : false)")
    WorkoutSession toSessionEntity(CreateWorkoutSessionRequest request, WorkoutPlan plan);

    @Mapping(target = "workoutSession", source = "session")
    @Mapping(target = "exercise", source = "exercise")
    @Mapping(target = "sets", source = "request.sets")
    @Mapping(target = "repetitions", source = "request.repetitions")
    @Mapping(target = "weightKg", source = "request.weightKg")
    @Mapping(target = "restTimeSeconds", source = "request.restTimeSeconds")
    @Mapping(target = "orderIndex", source = "request.orderIndex")
    @Mapping(target = "notes", source = "request.notes")
    @Mapping(target = "isSuperset", expression = "java(request.getIsSuperset() != null ? request.getIsSuperset() : false)")
    SessionExercise toSessionExerciseEntity(CreateSessionExerciseRequest request,
                                            WorkoutSession session,
                                            Exercise exercise);

    // ── Partial-update helpers (single source of truth) ──────────────────────

    default void applyPartialUpdate(WorkoutPlan plan,
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

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void applyPartialUpdate(@MappingTarget WorkoutSession session, UpdateWorkoutSessionRequest request);

    default void applyPartialUpdate(SessionExercise sessionExercise,
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

    @Override
    @Mapping(target = "goal", source = "goal")
    @Mapping(target = "muscleGroup", source = "muscleGroup")
    @Mapping(target = "difficultyLevel", expression = "java(plan.getDifficultyLevel() != null ? DifficultyLevel.valueOf(plan.getDifficultyLevel()) : null)")
    @Mapping(target = "scheduledWorkoutDates", expression = "java(plan.getScheduledWorkoutDates() != null ? new ArrayList<>(plan.getScheduledWorkoutDates()) : null)")
    @Mapping(target = "sessions", expression = "java(toSessionResponseList(plan.getWorkoutSessions()))")
    WorkoutPlanResponse toResponse(WorkoutPlan plan);

    @Mapping(target = "goalName", source = "goal.goalName")
    @Mapping(target = "muscleGroup", source = "muscleGroup")
    @Mapping(target = "difficultyLevel", expression = "java(plan.getDifficultyLevel() != null ? DifficultyLevel.valueOf(plan.getDifficultyLevel()) : null)")
    @Mapping(target = "sessionCount", expression = "java(plan.getWorkoutSessions() != null ? plan.getWorkoutSessions().size() : 0)")
    WorkoutPlanSummaryResponse toSummaryResponse(WorkoutPlan plan);

    GoalResponse toGoalResponse(Goal goal);

    default List<WorkoutSessionResponse> toSessionResponseList(Set<WorkoutSession> sessions) {
        if (sessions == null || sessions.isEmpty()) return Collections.emptyList();
        return sessions.stream()
                .sorted(Comparator.comparing(WorkoutSession::getDayNumber))
                .map(this::toSessionResponse)
                .collect(Collectors.toList());
    }

    default WorkoutSessionResponse toSessionResponse(WorkoutSession session) {
        return toSessionResponse(session, false, null);
    }

    default WorkoutSessionResponse toSessionResponse(WorkoutSession session, Boolean isCompleted) {
        return toSessionResponse(session, isCompleted, null);
    }

    @Mapping(target = "sessionId", source = "session.sessionId")
    @Mapping(target = "sessionName", source = "session.sessionName")
    @Mapping(target = "dayNumber", source = "session.dayNumber")
    @Mapping(target = "scheduledDate", source = "session.scheduledDate")
    @Mapping(target = "focusArea", source = "session.focusArea")
    @Mapping(target = "estimatedDuration", source = "session.estimatedDuration")
    @Mapping(target = "warmUpNotes", source = "session.warmUpNotes")
    @Mapping(target = "coolDownNotes", source = "session.coolDownNotes")
    @Mapping(target = "isRestDay", source = "session.isRestDay")
    @Mapping(target = "isCompleted", source = "isCompleted")
    @Mapping(target = "missedWorkoutId", source = "missedWorkoutId")
    @Mapping(target = "isMissed", expression = "java(missedWorkoutId != null)")
    @Mapping(target = "exercises", expression = "java(toSessionExerciseResponseList(session.getSessionExercises()))")
    WorkoutSessionResponse toSessionResponse(WorkoutSession session, Boolean isCompleted, Long missedWorkoutId);

    default List<SessionExerciseResponse> toSessionExerciseResponseList(List<SessionExercise> exercises) {
        if (exercises == null || exercises.isEmpty()) return Collections.emptyList();
        return exercises.stream()
                .sorted(Comparator.comparing(SessionExercise::getOrderIndex))
                .map(this::toSessionExerciseResponse)
                .collect(Collectors.toList());
    }

    @Mapping(target = "exercise", expression = "java(toExerciseSummary(se.getExercise()))")
    @Mapping(target = "equipmentUsed", expression = "java(extractEquipmentUsed(se))")
    SessionExerciseResponse toSessionExerciseResponse(SessionExercise se);

    default List<EquipmentResponse> extractEquipmentUsed(SessionExercise se) {
        if (se == null || se.getExercise() == null || se.getExercise().getExerciseEquipments() == null) {
            return Collections.emptyList();
        }
        return se.getExercise().getExerciseEquipments().stream()
                .map(ee -> toEquipmentResponse(ee.getEquipment()))
                .collect(Collectors.toList());
    }

    EquipmentResponse toEquipmentResponse(com.dev.backend.model.entity.Equipment equipment);

    ExerciseSummaryResponse toExerciseSummary(Exercise exercise);

    @Mapping(target = "goal", source = "goal")
    @Mapping(target = "muscleGroup", source = "muscleGroup")
    @Mapping(target = "difficultyLevel", expression = "java(plan.getDifficultyLevel() != null ? DifficultyLevel.valueOf(plan.getDifficultyLevel()) : null)")
    @Mapping(target = "endDate", expression = "java(plan.getStartDate() != null && plan.getDurationWeeks() != null ? plan.getStartDate().plusWeeks(plan.getDurationWeeks()).minusDays(1) : null)")
    @Mapping(target = "scheduledWorkoutDates", expression = "java(plan.getScheduledWorkoutDates() != null ? new ArrayList<>(plan.getScheduledWorkoutDates()) : null)")
    WorkoutPlanDetailResponse toDetailResponse(WorkoutPlan plan);

    @Mapping(target = "goal", source = "goal")
    @Mapping(target = "muscleGroup", source = "muscleGroup")
    @Mapping(target = "difficultyLevel", expression = "java(plan.getDifficultyLevel() != null ? DifficultyLevel.valueOf(plan.getDifficultyLevel()) : null)")
    @Mapping(target = "sessions", expression = "java(toSessionSummaryResponseList(plan.getWorkoutSessions()))")
    WorkoutPlanSummaryWithSessionsResponse toSummaryWithSessionsResponse(WorkoutPlan plan);

    default List<WorkoutSessionSummaryResponse> toSessionSummaryResponseList(Set<WorkoutSession> sessions) {
        if (sessions == null || sessions.isEmpty()) return Collections.emptyList();
        return sessions.stream()
                .sorted(Comparator.comparing(WorkoutSession::getDayNumber))
                .map(this::toSessionSummaryResponse)
                .collect(Collectors.toList());
    }

    @Mapping(target = "exerciseCount", expression = "java(session.getSessionExercises() != null ? session.getSessionExercises().size() : 0)")
    WorkoutSessionSummaryResponse toSessionSummaryResponse(WorkoutSession session);
}
