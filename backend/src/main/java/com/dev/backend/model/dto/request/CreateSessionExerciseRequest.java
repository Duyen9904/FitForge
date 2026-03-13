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
public class CreateSessionExerciseRequest {

    @NotNull(message = "Exercise ID is required")
    private String exerciseId;

    @NotNull(message = "Number of sets is required")
    @Min(value = 1, message = "Sets must be at least 1")
    @Max(value = 20, message = "Sets cannot exceed 20")
    private Integer sets;

    @NotNull(message = "Number of repetitions is required")
    @Min(value = 1, message = "Repetitions must be at least 1")
    @Max(value = 100, message = "Repetitions cannot exceed 100")
    private Integer repetitions;

    @Min(value = 0, message = "Weight cannot be negative")
    @Max(value = 1000, message = "Weight cannot exceed 1000 kg")
    private Float weightKg;

    @Min(value = 0, message = "Rest time cannot be negative")
    @Max(value = 600, message = "Rest time cannot exceed 600 seconds")
    private Integer restTimeSeconds;

    @NotNull(message = "Order index is required")
    @Min(value = 0, message = "Order index cannot be negative")
    private Integer orderIndex;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;

    private Boolean isSuperset = false;
}
