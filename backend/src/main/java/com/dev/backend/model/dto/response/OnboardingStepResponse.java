package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Response DTO for onboarding step with user's progress status.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OnboardingStepResponse {

    private Long stepId;
    private String stepKey;
    private String title;
    private String subtitle;
    private String helpText;
    private OnboardingStepType stepType;
    /** Renderable input type for frontend UI (single choice, multiple choice, text, etc.) */
    private OnboardingInputType inputType;
    private Integer displayOrder;
    private Boolean isRequired;
    private Boolean isActive;
    private String iconUrl;
    
    // User's progress on this step
    private OnboardingStepStatus status;
    private String responseData;
    private LocalDateTime completedAt;
    
    // Options for selection-based steps
    private List<OnboardingOptionResponse> options;
}
