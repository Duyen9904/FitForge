package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Request DTO for reordering onboarding steps (admin).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReorderOnboardingStepsRequest {

    @NotEmpty(message = "Step IDs are required")
    private List<Long> stepIds;
}
