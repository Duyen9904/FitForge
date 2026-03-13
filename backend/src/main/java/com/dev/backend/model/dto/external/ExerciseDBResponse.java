package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for ExerciseDB v2 API
 * Maps to the exercise data returned from https://exercisedbv2.ascendapi.com
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExerciseDBResponse {

    private String exerciseId;
    private String name;
    private String exerciseType;
    private String overview;
    private String imageUrl;

    @JsonProperty("targetMuscles")
    private List<String> targetMuscles;

    @JsonProperty("secondaryMuscles")
    private List<String> secondaryMuscles;

    @JsonProperty("bodyParts")
    private List<String> bodyParts;

    @JsonProperty("equipments")
    private List<String> equipments;

    @JsonProperty("instructions")
    private List<String> instructions;

    @JsonProperty("exerciseTips")
    private List<String> exerciseTips;

    @JsonProperty("keywords")
    private List<String> keywords;

    @JsonProperty("variations")
    private List<String> variations;

    @JsonProperty("relatedExerciseIds")
    private List<String> relatedExerciseIds;
}
