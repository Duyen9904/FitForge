package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * An exercise "slot" in an AI-generated workout structure.
 * Instead of specifying an exact exercise, the AI specifies the
 * muscle group and movement pattern (compound/isolation).
 * The backend ExerciseSelector fills in the real exercise.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiExerciseSlot {
    private String muscleGroup;      // e.g. "CHEST", "BACK", "LEGS", "ARMS", "SHOULDERS", "CORE", "GLUTES"
    private String movementPattern;  // "compound" or "isolation"
    private Integer sets;
    private String repetitions;      // e.g. "8-12", "15", "30 seconds"
    private Integer restTimeSeconds;
    private Integer orderIndex;
    private String notes;            // e.g. "focus on slow eccentric", "use light weight"
}
