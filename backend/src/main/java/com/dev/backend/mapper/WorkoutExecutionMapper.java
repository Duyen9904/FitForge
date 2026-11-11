package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CompleteWorkoutRequest;
import com.dev.backend.model.dto.response.ExerciseLogResponse;
import com.dev.backend.model.dto.response.WorkoutHistoryResponse;
import com.dev.backend.model.dto.response.WorkoutProgressResponse;
import com.dev.backend.model.entity.ExerciseLog;
import com.dev.backend.model.entity.WorkoutProgress;
import com.dev.backend.service.GcpService;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface WorkoutExecutionMapper extends BaseMapper<WorkoutProgress, CompleteWorkoutRequest, WorkoutProgressResponse> {

    Logger log = LoggerFactory.getLogger(WorkoutExecutionMapper.class);

    @Override
    @Mapping(target = "planId", source = "workoutPlan.planId")
    @Mapping(target = "planName", source = "workoutPlan.planName")
    @Mapping(target = "sessionId", source = "workoutSession.sessionId")
    @Mapping(target = "sessionName", source = "workoutSession.sessionName")
    @Mapping(target = "proofPhotoUrl", expression = "java(resolveSignedUrl(progress.getProofPhotoUrl(), null))")
    @Mapping(target = "exerciseLogs", expression = "java(toExerciseLogResponseList(progress.getExerciseLogs()))")
    WorkoutProgressResponse toResponse(WorkoutProgress progress);

    @Override
    WorkoutProgress toEntity(CompleteWorkoutRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget WorkoutProgress entity, CompleteWorkoutRequest request);

    default WorkoutProgressResponse toProgressResponse(WorkoutProgress progress) {
        return toProgressResponse(progress, null);
    }

    default WorkoutProgressResponse toProgressResponse(WorkoutProgress progress, GcpService gcpService) {
        if (progress == null) {
            return null;
        }
        WorkoutProgressResponse response = toResponse(progress);
        response.setProofPhotoUrl(resolveSignedUrl(progress.getProofPhotoUrl(), gcpService));
        return response;
    }

    default WorkoutHistoryResponse toHistoryResponse(WorkoutProgress progress) {
        if (progress == null) {
            return null;
        }
        int completed = 0;
        int skipped = 0;
        float totalVolume = 0f;

        if (progress.getExerciseLogs() != null) {
            for (ExerciseLog exerciseLog : progress.getExerciseLogs()) {
                if (Boolean.TRUE.equals(exerciseLog.getCompleted())) {
                    completed++;
                    if (exerciseLog.getRepetitionsCompleted() != null && exerciseLog.getWeightUsedKg() != null) {
                        totalVolume += exerciseLog.getRepetitionsCompleted() * exerciseLog.getWeightUsedKg();
                    }
                } else {
                    skipped++;
                }
            }
        }

        return WorkoutHistoryResponse.builder()
                .progressId(progress.getProgressId())
                .planName(progress.getWorkoutPlan() != null ? progress.getWorkoutPlan().getPlanName() : null)
                .sessionName(progress.getWorkoutSession() != null ? progress.getWorkoutSession().getSessionName() : null)
                .workoutDate(progress.getWorkoutDate())
                .durationMinutes(progress.getDurationMinutes())
                .completed(progress.getCompleted())
                .difficultyRating(progress.getDifficultyRating())
                .caloriesBurned(progress.getCaloriesBurned())
                .moodRating(progress.getMoodRating())
                .exercisesCompleted(completed)
                .exercisesSkipped(skipped)
                .totalVolumeKg(totalVolume)
                .proofPhotoUrl(resolveSignedUrl(progress.getProofPhotoUrl(), null))
                .build();
    }

    default String resolveSignedUrl(String objectPath, GcpService gcpService) {
        if (objectPath == null || objectPath.isBlank()) {
            return null;
        }
        if (gcpService == null) {
            return objectPath;
        }
        try {
            return gcpService.getSignedUrl(objectPath);
        } catch (Exception e) {
            log.warn("Failed to generate signed URL for {}: {}", objectPath, e.getMessage());
            return objectPath;
        }
    }

    default List<ExerciseLogResponse> toExerciseLogResponseList(List<ExerciseLog> logs) {
        if (logs == null) return Collections.emptyList();
        return logs.stream()
                .map(this::toExerciseLogResponse)
                .collect(Collectors.toList());
    }

    @Mapping(target = "exerciseId", source = "exercise.exerciseId")
    @Mapping(target = "exerciseName", source = "exercise.exerciseName")
    ExerciseLogResponse toExerciseLogResponse(ExerciseLog log);
}
