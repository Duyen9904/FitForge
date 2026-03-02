package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Complete AI-generated workout plan result, parsed from AI JSON response.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiWorkoutPlanResult {
    private String planName;
    private String description;
    private String recommendationReason;
    private List<AiSessionResult> sessions;
}
