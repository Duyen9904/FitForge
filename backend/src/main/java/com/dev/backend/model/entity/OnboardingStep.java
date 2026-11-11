package com.dev.backend.model.entity;

import com.dev.backend.model.dto.onboarding.OnboardingStepConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Defines a configurable onboarding step belonging to an OnboardingFlow.
 * Step UI metadata and selectable options are stored as JSON in config.
 */
@Entity
@Table(
    name = "onboarding_steps",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_onboarding_step_flow_key", columnNames = {"flow_id", "step_key"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class OnboardingStep {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flow_id", nullable = false)
    private OnboardingFlow flow;

    @Column(name = "step_key", nullable = false, length = 50)
    private String stepKey;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false)
    private Integer sequence;

    @Column(name = "is_required", nullable = false)
    private Boolean isRequired = true;

    @Column(columnDefinition = "JSON")
    private String config;

    @OneToMany(mappedBy = "step", cascade = CascadeType.ALL)
    private List<UserOnboardingStep> userOnboardingSteps = new ArrayList<>();

    /**
     * Convenience accessor to parse the JSON config into OnboardingStepConfig.
     */
    @Transient
    public OnboardingStepConfig getParsedConfig() {
        if (config == null || config.isBlank()) {
            return new OnboardingStepConfig();
        }
        try {
            return MAPPER.readValue(config, OnboardingStepConfig.class);
        } catch (JsonProcessingException e) {
            return new OnboardingStepConfig();
        }
    }

    /**
     * Convenience mutator to serialize OnboardingStepConfig into the JSON config column.
     */
    public void setParsedConfig(OnboardingStepConfig stepConfig) {
        if (stepConfig == null) {
            this.config = null;
            return;
        }
        try {
            this.config = MAPPER.writeValueAsString(stepConfig);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize OnboardingStepConfig", e);
        }
    }
}
