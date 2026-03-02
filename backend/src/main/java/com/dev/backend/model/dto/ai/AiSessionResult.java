package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * AI-generated workout session within a plan.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiSessionResult {
    private Integer dayNumber;
    private String sessionName;
    private String focusArea;
    private Integer estimatedDuration;
    private Boolean isRestDay;
    private String warmUpNotes;
    private String coolDownNotes;
    private List<AiExerciseResult> exercises;
}
