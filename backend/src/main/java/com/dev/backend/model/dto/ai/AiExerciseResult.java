package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * AI-generated exercise prescription for a single exercise within a session.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiExerciseResult {
    private String exerciseId;
    private String exerciseName; // fallback if exerciseId not found
    private Integer sets;
    private String repetitions;
    private Double weightKg;
    private Integer restTimeSeconds;
    private Integer orderIndex;
    private String notes;
}
