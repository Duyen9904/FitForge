package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Complete AI-generated workout plan structure.
 * Contains session structures with exercise slots (not concrete exercises).
 * The backend ExerciseSelector fills in real exercises from the database.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiStructureResult {
    private String planName;
    private String description;
    private String recommendationReason;
    private List<AiSessionStructure> sessions;
}
