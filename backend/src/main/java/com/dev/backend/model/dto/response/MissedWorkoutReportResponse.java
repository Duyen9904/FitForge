package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * Response DTO for missed workout consistency report (UC-6.4)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MissedWorkoutReportResponse {

    private Integer totalMissedWorkouts;
    private Integer totalCompletedWorkouts;
    private Float adherencePercentage;
    private Integer compensationCompletionRate;
    
    private MissedWorkoutPatterns patterns;
    private List<String> recommendations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MissedWorkoutPatterns {
        // Count by day of week (1=Sunday, 7=Saturday)
        private Map<String, Integer> byDayOfWeek;
        // Count by reason
        private Map<String, Integer> byReason;
        // Most common day to miss
        private String mostMissedDay;
        // Most common reason
        private String mostCommonReason;
    }
}
