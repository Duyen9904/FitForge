package com.dev.backend.model.entity;

import com.dev.backend.model.enums.OnboardingStepType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Defines a configurable onboarding step.
 * Admin can create, reorder, enable/disable steps.
 */
@Entity
@Table(
    name = "onboarding_step",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_onboarding_step_key", columnNames = "step_key")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class OnboardingStep {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long stepId;

    @Column(name = "step_key", nullable = false, unique = true, length = 50)
    private String stepKey;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(length = 500)
    private String helpText;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private OnboardingStepType stepType;

    @Column(nullable = false)
    private Integer displayOrder;

    @Column(nullable = false)
    private Boolean isRequired = true;

    @Column(nullable = false)
    private Boolean isActive = true;

    @Column(length = 255)
    private String iconUrl;

    @OneToMany(mappedBy = "step", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("displayOrder ASC")
    private List<OnboardingOption> options = new ArrayList<>();

    @OneToMany(mappedBy = "step", cascade = CascadeType.ALL)
    private List<UserOnboardingProgress> userProgress = new ArrayList<>();
}
