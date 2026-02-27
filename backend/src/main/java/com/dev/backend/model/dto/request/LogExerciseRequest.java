package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LogExerciseRequest {

    @NotNull(message = "Exercise ID is required")
    private Long exerciseId;

    @NotNull(message = "Set number is required")
    @Min(value = 1, message = "Set number must be at least 1")
    private Integer setNumber;

    @Min(value = 0, message = "Repetitions cannot be negative")
    @Max(value = 100, message = "Repetitions cannot exceed 100")
    private Integer repetitionsCompleted;

    @Min(value = 0, message = "Weight cannot be negative")
    @Max(value = 1000, message = "Weight cannot exceed 1000 kg")
    private Float weightUsedKg;

    @Min(value = 0, message = "Rest time cannot be negative")
    private Integer restTimeSeconds;

    private Boolean completed = true;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;
}
