package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutSummaryReportResponse {

    private LocalDate startDate;
    private LocalDate endDate;

    // Workout Statistics
    private Integer totalWorkoutsCompleted;
    private Integer totalWorkoutsPlanned;
    private Double adherencePercentage;
    private Integer totalDurationMinutes;
    private Integer totalCaloriesBurned;

    // Volume Analysis
    private Map<String, Double> volumeByMuscleGroup;  // muscle group name -> total volume (kg)
    private List<ExerciseProgressItem> mostImprovedExercises;

    // Missed Workout Analysis
    private Integer missedWorkouts;
    private Map<String, Integer> missedReasonBreakdown;

    // Recommendations
    private List<String> recommendations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExerciseProgressItem {
        private String exerciseName;
        private Double startingWeight;
        private Double currentWeight;
        private Double improvementPercentage;
    }
}
