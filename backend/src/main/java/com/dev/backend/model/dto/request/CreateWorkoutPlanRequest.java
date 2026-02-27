package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateWorkoutPlanRequest {

    @NotBlank(message = "Plan name is required")
    @Size(max = 100, message = "Plan name must not exceed 100 characters")
    private String planName;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @NotNull(message = "Goal ID is required")
    private Long goalId;

    @NotNull(message = "Muscle group ID is required")
    private Long muscleGroupId;

    @NotNull(message = "Frequency per week is required")
    @Min(value = 1, message = "Frequency must be at least 1 day per week")
    @Max(value = 7, message = "Frequency cannot exceed 7 days per week")
    private Integer frequencyPerWeek;

    @NotNull(message = "Duration in weeks is required")
    @Min(value = 1, message = "Duration must be at least 1 week")
    @Max(value = 52, message = "Duration cannot exceed 52 weeks")
    private Integer durationWeeks;

    @NotNull(message = "Difficulty level is required")
    private DifficultyLevel difficultyLevel;

    @NotNull(message = "Start date is required")
    @FutureOrPresent(message = "Start date must be today or in the future")
    private LocalDate startDate;

    private Boolean allowWorkoutSwaps = true;

    /**
     * Optional. User-chosen specific workout dates (e.g. Mon, Wed, Fri for the first weeks).
     * When provided, these dates are stored and can be used when adding sessions.
     */
    private List<LocalDate> workoutDates;
}
