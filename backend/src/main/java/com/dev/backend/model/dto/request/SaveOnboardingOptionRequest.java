package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating or updating an onboarding option (admin).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SaveOnboardingOptionRequest {

    @NotBlank(message = "Option key is required")
    @Size(max = 50, message = "Option key must be at most 50 characters")
    private String optionKey;

    @NotBlank(message = "Label is required")
    @Size(max = 100, message = "Label must be at most 100 characters")
    private String label;

    @Size(max = 255, message = "Description must be at most 255 characters")
    private String description;

    @Size(max = 255, message = "Icon URL must be at most 255 characters")
    private String iconUrl;

    private Integer displayOrder;

    private Boolean isActive = true;

    /** JSON metadata for additional configuration */
    private String metadata;
    
    /**
     * Optional goal ID to link this option to.
     * Only relevant for FITNESS_GOAL step options.
     */
    private Long goalId;
}
