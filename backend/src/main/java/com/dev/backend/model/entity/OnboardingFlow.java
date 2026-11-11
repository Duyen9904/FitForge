package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Defines a versioned onboarding flow containing ordered steps.
 */
@Entity
@Table(
    name = "onboarding_flows",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_onboarding_flow_key_version", columnNames = {"flow_key", "version"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class OnboardingFlow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;

    @Column(name = "flow_key", nullable = false, length = 50)
    private String flowKey;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false)
    private Integer version = 1;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @OneToMany(mappedBy = "flow", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sequence ASC")
    private List<OnboardingStep> steps = new ArrayList<>();

    @OneToMany(mappedBy = "flow", cascade = CascadeType.ALL)
    private List<UserOnboarding> userOnboardings = new ArrayList<>();
}
