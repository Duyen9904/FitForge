package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProgressChartResponse {

    private Instant fromDate;
    private Instant toDate;
    
    // Weight progression per exercise
    private List<ExerciseProgressData> weightProgression;
    
    // Volume per muscle group over time
    private Map<String, List<VolumeDataPoint>> volumeByMuscleGroup;
    
    // Workout frequency
    private List<FrequencyDataPoint> workoutFrequency;
    
    // Calories burned trend
    private List<CaloriesDataPoint> caloriesTrend;
    
    // Strength estimates (1RM)
    private List<StrengthEstimate> strengthEstimates;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExerciseProgressData {
        private String exerciseId;
        private String exerciseName;
        private List<WeightDataPoint> dataPoints;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeightDataPoint {
        private Instant date;
        private Float maxWeight;
        private Float avgWeight;
        private Integer totalReps;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VolumeDataPoint {
        private Instant date;
        private Float totalVolume;
        private Integer totalSets;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FrequencyDataPoint {
        private String weekLabel;
        private Integer workoutsCompleted;
        private Integer workoutsPlanned;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CaloriesDataPoint {
        private Instant date;
        private Integer caloriesBurned;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StrengthEstimate {
        private String exerciseId;
        private String exerciseName;
        private Float estimated1RM;
        private Float previousEstimated1RM;
        private Float percentChange;
    }
}
