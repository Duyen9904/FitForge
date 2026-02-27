package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import com.dev.backend.model.enums.ExerciseType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateExerciseRequest {

    @NotBlank(message = "Exercise name is required")
    @Size(max = 100, message = "Exercise name must not exceed 100 characters")
    private String exerciseName;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    @NotNull(message = "Difficulty level is required")
    private DifficultyLevel difficultyLevel;

    @NotNull(message = "Exercise type is required")
    private ExerciseType exerciseType;

    @Size(max = 2000, message = "Instructions must not exceed 2000 characters")
    private String instructions;

    private String videoUrl;

    private String imageUrl;

    @Min(value = 1, message = "Calories burned must be at least 1")
    @Max(value = 100, message = "Calories burned cannot exceed 100 per minute")
    private Integer caloriesBurnedPerMin;

    private Boolean requiresSpotter = false;

    @Size(max = 50, message = "Equipment category must not exceed 50 characters")
    private String equipmentCategory;

    private List<Long> primaryMuscleGroupIds;
    private List<Long> secondaryMuscleGroupIds;
    private List<Long> equipmentIds;
}
