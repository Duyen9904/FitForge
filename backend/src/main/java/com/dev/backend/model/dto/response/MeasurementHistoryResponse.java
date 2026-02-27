package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for measurement history with trends (UC-8.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeasurementHistoryResponse {

    private List<MeasurementResponse> measurements;
    private MeasurementTrendResponse trends;
    private ProgressIndicators progressIndicators;
    private GoalComparison goalComparison;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MeasurementTrendResponse {
        private List<TrendPoint> weightTrend;
        private List<TrendPoint> bodyFatTrend;
        private List<TrendPoint> waistTrend;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TrendPoint {
        private LocalDate date;
        private Float value;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProgressIndicators {
        private Float totalWeightChange;
        private Float totalBodyFatChange;
        private Float averageWeeklyWeightChange;
        private String overallTrend; // "gaining", "losing", "maintaining"
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GoalComparison {
        private Float currentWeight;
        private Float targetWeight;
        private Float remainingToTarget;
        private Float percentageComplete;
    }
}
