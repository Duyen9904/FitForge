package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStepType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating or updating an onboarding step (admin).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SaveOnboardingStepRequest {

    @NotBlank(message = "Step key is required")
    @Size(max = 50, message = "Step key must be at most 50 characters")
    private String stepKey;

    @NotBlank(message = "Title is required")
    @Size(max = 100, message = "Title must be at most 100 characters")
    private String title;

    @Size(max = 255, message = "Subtitle must be at most 255 characters")
    private String subtitle;

    @Size(max = 500, message = "Help text must be at most 500 characters")
    private String helpText;

    @NotNull(message = "Step type is required")
    private OnboardingStepType stepType;

    private OnboardingInputType inputType;

    private Integer displayOrder;

    @Builder.Default
    private Boolean isRequired = true;

    @Builder.Default
    private Boolean isActive = true;

    @Size(max = 255, message = "Icon URL must be at most 255 characters")
    private String iconUrl;
}
