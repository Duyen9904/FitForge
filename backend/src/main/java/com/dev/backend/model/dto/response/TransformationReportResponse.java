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
public class TransformationReportResponse {

    private LocalDate startDate;
    private LocalDate endDate;

    // Weight Changes
    private Float startingWeight;
    private Float currentWeight;
    private Float weightChange;
    private Float targetWeight;
    private Double progressToTargetPercentage;

    // Body Measurements Comparison
    private MeasurementComparison beforeMeasurements;
    private MeasurementComparison afterMeasurements;
    private Map<String, Float> measurementChanges;  // e.g., "chest" -> +2.5

    // Progress Photos
    private List<ProgressPhotoItem> progressPhotos;

    // Weight Chart Data
    private List<WeightDataPoint> weightHistory;


    // Correlation Data
    private Double workoutVolumeCorrelation;
    private Double nutritionAdherenceCorrelation;

    // Milestones
    private List<String> milestones;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MeasurementComparison {
        private LocalDate date;
        private Float weight;
        private Float bodyFatPercentage;
        private Float chestCm;
        private Float waistCm;
        private Float hipsCm;
        private Float bicepsCm;
        private Float thighsCm;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProgressPhotoItem {
        private Long photoId;
        private LocalDate date;
        private String photoUrl;
        private String category;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeightDataPoint {
        private LocalDate date;
        private Float weight;
    }
}
