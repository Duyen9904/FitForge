package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ExerciseResponse {

    private String exerciseId;
    private String exerciseName;
    private String description;
    private String difficultyLevel;
    private String exerciseType;
    private String instructions;
    private String videoUrl;
    private String imageUrl;
    private Integer caloriesBurnedPerMin;
    private Boolean requiresSpotter;
    private String equipmentCategory;
    private List<MuscleGroupResponse> primaryMuscleGroups;
    private List<MuscleGroupResponse> secondaryMuscleGroups;
    private List<EquipmentResponse> equipment;
    private List<ExerciseAlternativeResponse> alternatives;
}
