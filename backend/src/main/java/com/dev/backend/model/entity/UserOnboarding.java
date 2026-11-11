package com.dev.backend.model.entity;

import com.dev.backend.model.enums.OnboardingStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Tracks a user's onboarding session for a specific OnboardingFlow.
 */
@Entity
@Table(name = "user_onboardings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class UserOnboarding {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flow_id", nullable = false)
    private OnboardingFlow flow;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OnboardingStatus status = OnboardingStatus.IN_PROGRESS;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_step_id")
    private OnboardingStep currentStep;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @OneToMany(mappedBy = "onboarding", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserOnboardingStep> steps = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (startedAt == null) {
            startedAt = LocalDateTime.now();
        }
    }
}
