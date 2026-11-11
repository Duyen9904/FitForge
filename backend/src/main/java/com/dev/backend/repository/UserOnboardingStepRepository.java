package com.dev.backend.repository;

import com.dev.backend.model.entity.UserOnboardingStep;
import com.dev.backend.model.entity.UserOnboardingStepId;
import com.dev.backend.model.enums.OnboardingStepStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserOnboardingStepRepository extends JpaRepository<UserOnboardingStep, UserOnboardingStepId> {

    /**
     * Get all step records for a user's onboarding session.
     */
    List<UserOnboardingStep> findByOnboardingId(Long onboardingId);

    /**
     * Get all step records for a user across their onboarding sessions.
     */
    List<UserOnboardingStep> findByOnboardingUserUserId(Long userId);

    /**
     * Get progress for a specific onboarding session and step.
     */
    Optional<UserOnboardingStep> findByOnboardingIdAndStepId(Long onboardingId, Long stepId);

    /**
     * Check if a specific step in an onboarding session has the given status.
     */
    boolean existsByOnboardingIdAndStepIdAndStatus(Long onboardingId, Long stepId, OnboardingStepStatus status);

    /**
     * Count user step records for a given step and status.
     */
    long countByStepIdAndStatus(Long stepId, OnboardingStepStatus status);

    /**
     * Count distinct users who completed at least one step in a date range.
     */
    @Query("SELECT COUNT(DISTINCT s.onboarding.user.userId) FROM UserOnboardingStep s " +
           "WHERE s.status = 'COMPLETED' AND s.completedAt BETWEEN :from AND :to")
    long countUsersCompletedBetween(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    /**
     * Get completion/skip count per step (for analytics).
     */
    @Query("SELECT s.step.id, COUNT(s) FROM UserOnboardingStep s " +
           "WHERE s.status = :status GROUP BY s.step.id")
    List<Object[]> countByStepAndStatus(@Param("status") OnboardingStepStatus status);
}
