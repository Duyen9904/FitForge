package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import jakarta.validation.Valid;
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
public class UpdateWorkoutPlanRequest {

    @Size(max = 100, message = "Plan name must not exceed 100 characters")
    private String planName;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private Long goalId;

    private Long muscleGroupId;

    @Min(value = 1, message = "Frequency must be at least 1 day per week")
    @Max(value = 7, message = "Frequency cannot exceed 7 days per week")
    private Integer frequencyPerWeek;

    @Min(value = 1, message = "Duration must be at least 1 week")
    @Max(value = 52, message = "Duration cannot exceed 52 weeks")
    private Integer durationWeeks;

    private DifficultyLevel difficultyLevel;

    private Boolean allowWorkoutSwaps;

    /**
     * Optional. User-chosen specific workout dates. When provided, replaces the plan's scheduled workout dates.
     */
    private List<LocalDate> workoutDates;

    /**
     * Optional. When provided, performs a partial update of sessions and their exercises.
     * Existing sessions or session exercises that are not referenced here are left unchanged;
     * they are not deleted. To remove a specific session exercise, use the dedicated
     * session-exercise delete endpoint.
     */
    @Valid
    private List<UpdateWorkoutSessionRequest> sessions;
}
