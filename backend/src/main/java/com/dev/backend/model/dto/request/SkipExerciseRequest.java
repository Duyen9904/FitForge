package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.SkipReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkipExerciseRequest {

    @NotNull(message = "Exercise ID is required")
    private String exerciseId;

    @NotNull(message = "Skip reason is required")
    private SkipReason reason;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;
}
