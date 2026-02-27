package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for rescheduling a missed workout (UC-6.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RescheduleMissedWorkoutRequest {

    @NotNull(message = "New date is required")
    @Future(message = "New date must be in the future")
    private LocalDate newDate;

    private String notes;
}
