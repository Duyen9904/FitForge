package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStepStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Response DTO for user's progress on an onboarding step.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OnboardingProgressResponse {

    private Long stepId;
    private String stepKey;
    /** Renderable input type for this step (for frontend UI). */
    private OnboardingInputType inputType;
    private OnboardingStepStatus status;
    private String responseData;
    private LocalDateTime completedAt;
    
    /** Next step to complete (null if this was the last step) */
    private Long nextStepId;
    
    /** Whether all required steps are now complete */
    private Boolean onboardingComplete;
}
