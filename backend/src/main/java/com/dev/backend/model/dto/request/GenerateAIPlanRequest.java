package com.dev.backend.model.dto.request;

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

    @NotEmpty(message = "At least one target muscle group is required")
    private List<TargetMuscleGroup> targetMuscleGroups;

    @NotNull(message = "Duration in weeks is required")
    @Min(value = 1, message = "Duration must be at least 1 week")
    @Max(value = 52, message = "Duration cannot exceed 52 weeks")
    private Integer durationWeeks;

    @NotNull(message = "Start date is required")
    @FutureOrPresent(message = "Start date must be today or in the future")
    private LocalDate startDate;

    /** Free-text field for user to describe additional preferences the system doesn't ask about */
    @Size(max = 1000, message = "Additional information must not exceed 1000 characters")
    private String additionalInformation;
}
