package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import com.dev.backend.model.enums.TargetMuscleGroup;
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
public class GenerateAIPlanRequest {

    @NotNull(message = "Goal ID is required")
    private Long goalId;

    @NotEmpty(message = "At least one target muscle group is required")
    private List<TargetMuscleGroup> targetMuscleGroups;

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

    private List<Long> availableEquipmentIds;

    @Min(value = 15, message = "Session duration must be at least 15 minutes")
    @Max(value = 180, message = "Session duration cannot exceed 180 minutes")
    private Integer preferredSessionDuration;
}
