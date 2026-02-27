package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Selectable options for onboarding steps (e.g., fitness levels, equipment items).
 * Admin can configure options per step.
 */
@Entity
@Table(
    name = "onboarding_option",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_onboarding_option_step_key", columnNames = {"step_id", "option_key"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class OnboardingOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long optionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "step_id", nullable = false)
    private OnboardingStep step;

    @Column(name = "option_key", nullable = false, length = 50)
    private String optionKey;

    @Column(nullable = false, length = 100)
    private String label;

    @Column(length = 255)
    private String description;

    @Column(length = 255)
    private String iconUrl;

    @Column(nullable = false)
    private Integer displayOrder;

    @Column(nullable = false)
    private Boolean isActive = true;

    /** JSON metadata for additional configuration */
    @Column(columnDefinition = "TEXT")
    private String metadata;

    /**
     * Optional FK to Goal entity.
     * Only populated for FITNESS_GOAL step options to create a direct link
     * between onboarding options and fitness goals, avoiding fragile string matching.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id")
    private Goal goal;
}
