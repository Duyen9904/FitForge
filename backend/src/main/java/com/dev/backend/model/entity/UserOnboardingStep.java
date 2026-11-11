package com.dev.backend.model.entity;

import com.dev.backend.model.enums.OnboardingStepStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Tracks a user's progress and answer for an individual step within a UserOnboarding session.
 */
@Entity
@Table(name = "user_onboarding_steps")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class UserOnboardingStep {

    @EmbeddedId
    @EqualsAndHashCode.Include
    private UserOnboardingStepId id = new UserOnboardingStepId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("onboardingId")
    @JoinColumn(name = "onboarding_id", nullable = false)
    private UserOnboarding onboarding;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("stepId")
    @JoinColumn(name = "step_id", nullable = false)
    private OnboardingStep step;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OnboardingStepStatus status = OnboardingStepStatus.PENDING;

    /** JSON data storing user's answer for this step */
    @Column(name = "answer_data", columnDefinition = "JSON")
    private String answerData;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (startedAt == null) {
            startedAt = now;
        }
        if (updatedAt == null) {
            updatedAt = now;
        }
        if ((status == OnboardingStepStatus.COMPLETED || status == OnboardingStepStatus.SKIPPED) && completedAt == null) {
            completedAt = now;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        LocalDateTime now = LocalDateTime.now();
        updatedAt = now;
        if ((status == OnboardingStepStatus.COMPLETED || status == OnboardingStepStatus.SKIPPED) && completedAt == null) {
            completedAt = now;
        }
    }
}
