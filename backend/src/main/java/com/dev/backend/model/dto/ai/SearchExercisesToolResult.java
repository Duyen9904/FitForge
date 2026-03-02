package com.dev.backend.model.dto.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Result DTO returned to the LLM after executing the search_exercises tool.
 * Contains a list of real exercises from ExerciseDB so the AI can pick from them.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SearchExercisesToolResult {

    private List<ExerciseInfo> exercises;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExerciseInfo {
        private String id;
        private String name;
        private String target;
        private String bodyPart;
        private String equipment;
    }
}
