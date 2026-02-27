package com.dev.backend.model.dto.request;

import jakarta.validation.Valid;
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
public class UpdateWorkoutSessionRequest {

    private Long sessionId;

    @Size(max = 100, message = "Session name must not exceed 100 characters")
    private String sessionName;

    @Min(value = 1, message = "Day number must be at least 1")
    @Max(value = 7, message = "Day number cannot exceed 7")
    private Integer dayNumber;

    @Size(max = 100, message = "Focus area must not exceed 100 characters")
    private String focusArea;

    @Min(value = 1, message = "Estimated duration must be at least 1 minute")
    private Integer estimatedDuration;

    @Size(max = 500, message = "Warm-up notes must not exceed 500 characters")
    private String warmUpNotes;

    @Size(max = 500, message = "Cool-down notes must not exceed 500 characters")
    private String coolDownNotes;

    private Boolean isRestDay;

    @Valid
    private List<UpdateSessionExerciseRequest> exercises;
}
