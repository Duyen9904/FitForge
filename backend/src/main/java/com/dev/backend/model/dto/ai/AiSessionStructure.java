package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * AI-generated workout session structure.
 * Contains exercise slots (muscle group + pattern) instead of concrete exercises.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiSessionStructure {
    private Integer dayNumber;
    private String sessionName;
    private String focusArea;
    private Integer estimatedDuration;
    private Boolean isRestDay;
    private String warmUpNotes;
    private String coolDownNotes;
    private List<AiExerciseSlot> exerciseSlots;
}
