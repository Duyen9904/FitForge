package com.dev.backend.model.dto.ai;

import lombok.Builder;
import lombok.Value;

/**
 * Lightweight DTO to send exercise catalog info to the AI prompt.
 * Keeps token usage minimal while providing enough context for selection.
 */
@Value
@Builder
public class ExerciseSummary {
    Long id;
    String name;
    String muscleGroup;
    String type;
    String difficulty;
    String equipment;
}
