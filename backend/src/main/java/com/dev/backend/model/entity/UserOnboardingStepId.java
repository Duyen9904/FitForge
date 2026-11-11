package com.dev.backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

/**
 * Composite primary key for UserOnboardingStep (onboarding_id, step_id).
 */
@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class UserOnboardingStepId implements Serializable {

    @Column(name = "onboarding_id")
    private Long onboardingId;

    @Column(name = "step_id")
    private Long stepId;
}
