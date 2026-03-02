package com.dev.backend.model.dto.ai;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Tool parameter POJO for the search_exercises function call.
 * The AI agent calls this tool to discover which exercises are available
 * in the ExerciseDB before creating a plan.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonClassDescription("Search for available exercises by body part and/or equipment type. "
        + "Call this FIRST before creating a plan to discover real exercises.")
public class SearchExercisesToolParams {

    @JsonPropertyDescription("List of body parts to search, e.g. [\"chest\", \"back\", \"upper legs\"]. "
            + "Use ExerciseDB body part names.")
    private List<String> bodyParts;

    @JsonPropertyDescription("List of equipment types to filter by, e.g. [\"barbell\", \"dumbbell\", \"body weight\"]. "
            + "Use ExerciseDB equipment names.")
    private List<String> equipment;

    @JsonPropertyDescription("Maximum number of exercises to return per body part query. Default 10.")
    private Integer limit;
}
