package com.dev.backend.model.dto.onboarding;

import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStepType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Structured representation of the JSON stored in onboarding_steps.config.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class OnboardingStepConfig {

    private String subtitle;
    private String helpText;
    private OnboardingStepType stepType;
    private OnboardingInputType inputType;
    private String iconUrl;

    @Builder.Default
    private Boolean isActive = true;

    @Builder.Default
    private List<OnboardingOptionItem> options = new ArrayList<>();

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class OnboardingOptionItem {
        private Long optionId;
        private String optionKey;
        private String label;
        private String description;
        private String iconUrl;
        private Integer displayOrder;

        @Builder.Default
        private Boolean isActive = true;

        private String metadata;
        private Long goalId;
    }
}
