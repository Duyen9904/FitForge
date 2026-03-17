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
public class ExerciseSuggestionResponse {

    private String exerciseId;
    private String exerciseName;
    private String imageUrl;
    private Integer defaultSets;
    private Integer defaultReps;
    private Double defaultWeightKg;
    private Integer defaultRestSeconds;
}
