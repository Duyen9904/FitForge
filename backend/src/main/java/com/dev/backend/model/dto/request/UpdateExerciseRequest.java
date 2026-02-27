package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Request DTO for updating an exercise (UC-16.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateExerciseRequest {

    @Size(max = 100, message = "Exercise name must be at most 100 characters")
    private String exerciseName;

    @Size(max = 1000, message = "Description must be at most 1000 characters")
    private String description;

    @Size(max = 2000, message = "Instructions must be at most 2000 characters")
    private String instructions;

    @Size(max = 500, message = "Video URL must be at most 500 characters")
    private String videoUrl;

    @Size(max = 500, message = "Image URL must be at most 500 characters")
    private String imageUrl;

    private String difficultyLevel;

    private String exerciseType;

    /**
     * List of muscle group IDs to associate with this exercise
     */
    private List<Long> muscleGroupIds;

    /**
     * List of equipment IDs required for this exercise
     */
    private List<Long> equipmentIds;
}
