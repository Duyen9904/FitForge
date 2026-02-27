package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for ExerciseDB API
 * Maps to the exercise data returned from https://exercisedb.p.rapidapi.com
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExerciseDBResponse {

    private String id;
    private String name;
    private String gifUrl;
    private String target; // Primary muscle group
    private String bodyPart;
    private String equipment;
    private String[] secondaryMuscles;
    private String[] instructions;
}
