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
 * Tracks each user's progress through onboarding steps.
 * Records status (PENDING/COMPLETED/SKIPPED) and user responses.
 */
@Entity
@Table(
    name = "user_onboarding_progress",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_onboarding_progress", columnNames = {"user_id", "step_id"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class UserOnboardingProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long progressId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "step_id", nullable = false)
    private OnboardingStep step;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OnboardingStepStatus status = OnboardingStepStatus.PENDING;

    /** JSON data storing user's response for this step */
    @Column(columnDefinition = "TEXT")
    private String responseData;

    private LocalDateTime completedAt;

    @PreUpdate
    protected void onUpdate() {
        if (status == OnboardingStepStatus.COMPLETED && completedAt == null) {
            completedAt = LocalDateTime.now();
        }
    }
}
