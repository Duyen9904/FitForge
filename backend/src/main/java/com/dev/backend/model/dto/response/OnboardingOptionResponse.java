package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for onboarding option details.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OnboardingOptionResponse {

    private Long optionId;
    private String optionKey;
    private String label;
    private String description;
    private String iconUrl;
    private Integer displayOrder;
    private Boolean isActive;
    private String metadata;
    
    /**
     * Optional goal ID that this option links to.
     * Only populated for FITNESS_GOAL step options.
     */
    private Long goalId;
}
