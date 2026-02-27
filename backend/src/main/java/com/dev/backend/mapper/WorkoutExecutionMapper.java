package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.ExerciseLogResponse;
import com.dev.backend.model.dto.response.WorkoutHistoryResponse;
import com.dev.backend.model.dto.response.WorkoutProgressResponse;
import com.dev.backend.model.entity.ExerciseLog;
import com.dev.backend.model.entity.WorkoutProgress;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class WorkoutExecutionMapper {

    public WorkoutProgressResponse toProgressResponse(WorkoutProgress progress) {
        return WorkoutProgressResponse.builder()
                .progressId(progress.getProgressId())
                .planId(progress.getWorkoutPlan() != null ? progress.getWorkoutPlan().getPlanId() : null)
                .planName(progress.getWorkoutPlan() != null ? progress.getWorkoutPlan().getPlanName() : null)
                .sessionId(progress.getWorkoutSession() != null ? progress.getWorkoutSession().getSessionId() : null)
                .sessionName(progress.getWorkoutSession() != null ? progress.getWorkoutSession().getSessionName() : null)
                .workoutDate(progress.getWorkoutDate())
                .startTime(progress.getStartTime())
                .endTime(progress.getEndTime())
                .durationMinutes(progress.getDurationMinutes())
                .completed(progress.getCompleted())
                .performanceNotes(progress.getPerformanceNotes())
                .difficultyRating(progress.getDifficultyRating())
                .caloriesBurned(progress.getCaloriesBurned())
                .averageHeartRate(progress.getAverageHeartRate())
                .moodRating(progress.getMoodRating())
                .exerciseLogs(toExerciseLogResponseList(progress.getExerciseLogs()))
                .build();
    }

    public WorkoutHistoryResponse toHistoryResponse(WorkoutProgress progress) {
        int completed = 0;
        int skipped = 0;
        float totalVolume = 0f;

        if (progress.getExerciseLogs() != null) {
            for (ExerciseLog log : progress.getExerciseLogs()) {
                if (Boolean.TRUE.equals(log.getCompleted())) {
                    completed++;
                    if (log.getRepetitionsCompleted() != null && log.getWeightUsedKg() != null) {
                        totalVolume += log.getRepetitionsCompleted() * log.getWeightUsedKg();
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
                .build();
    }

    public List<ExerciseLogResponse> toExerciseLogResponseList(List<ExerciseLog> logs) {
        if (logs == null) return Collections.emptyList();
        return logs.stream()
                .map(this::toExerciseLogResponse)
                .collect(Collectors.toList());
    }

    public ExerciseLogResponse toExerciseLogResponse(ExerciseLog log) {
        return ExerciseLogResponse.builder()
                .logId(log.getLogId())
                .exerciseId(log.getExercise() != null ? log.getExercise().getExerciseId() : null)
                .exerciseName(log.getExercise() != null ? log.getExercise().getExerciseName() : null)
                .setNumber(log.getSetNumber())
                .repetitionsCompleted(log.getRepetitionsCompleted())
                .weightUsedKg(log.getWeightUsedKg())
                .restTimeSeconds(log.getRestTimeSeconds())
                .completed(log.getCompleted())
                .notes(log.getNotes())
                .build();
    }
}
