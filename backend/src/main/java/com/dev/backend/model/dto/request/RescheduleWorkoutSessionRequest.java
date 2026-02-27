package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.RescheduleReason;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for rescheduling an upcoming (not-yet-missed) workout session
 * within a workout plan.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RescheduleWorkoutSessionRequest {

    @NotNull(message = "New date is required")
    @FutureOrPresent(message = "New date must be today or in the future")
    private LocalDate newDate;

    /**
     * Optional high-level trigger for the reschedule, aligned with
     * {@link RescheduleReason}. For example:
     * - USER_INITIATED
     * - SYSTEM_DEFAULT
     */
    private RescheduleReason rescheduleReason;

    /**
     * Optional free-form notes explaining why the session is being moved.
     */
    private String notes;
}

