package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ExerciseRecommendationResponse {

    private Long exerciseId;
    private String exerciseName;
    private String description;
    private String difficultyLevel;
    private String exerciseType;
    private String primaryMuscleGroup;
    private String rationale;  // e.g., "Complement chest press with rows for balance"
    private Integer relevanceScore;  // 1-100 score for sorting
}
