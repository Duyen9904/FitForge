package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MoodRating;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CompleteWorkoutRequest {

    @NotNull(message = "Difficulty rating is required")
    @Min(value = 1, message = "Difficulty rating must be between 1 and 5")
    @Max(value = 5, message = "Difficulty rating must be between 1 and 5")
    private Integer difficultyRating;

    @Size(max = 1000, message = "Performance notes must not exceed 1000 characters")
    private String performanceNotes;

    private MoodRating moodRating;
}
