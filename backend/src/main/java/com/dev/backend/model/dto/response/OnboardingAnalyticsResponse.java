package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * Response DTO for onboarding analytics (admin).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OnboardingAnalyticsResponse {

    /** Total users who started onboarding */
    private Long totalUsersStarted;
    
    /** Total users who completed all required steps */
    private Long totalUsersCompleted;
    
    /** Overall completion rate (0.0 to 1.0) */
    private Double completionRate;
    
    /** Completion count per step (stepId -> count) */
    private Map<Long, Long> completionsByStep;
    
    /** Skip count per step (stepId -> count) */
    private Map<Long, Long> skipsByStep;
    
    /** Popular option selections per step (stepKey -> optionKey -> count) */
    private Map<String, Map<String, Long>> popularOptionsByStep;
}
