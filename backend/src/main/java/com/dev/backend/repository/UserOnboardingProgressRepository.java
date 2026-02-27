package com.dev.backend.repository;

import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserOnboardingProgressRepository extends JpaRepository<UserOnboardingProgress, Long> {

    /**
     * Get all progress entries for a user.
     */
    List<UserOnboardingProgress> findByUserUserId(Long userId);

    /**
     * Get progress for a specific user and step.
     */
    Optional<UserOnboardingProgress> findByUserUserIdAndStepStepId(Long userId, Long stepId);

    /**
     * Check if user has completed a specific step.
     */
    boolean existsByUserUserIdAndStepStepIdAndStatus(Long userId, Long stepId, OnboardingStepStatus status);

    /**
     * Count completed steps for a user.
     */
    long countByUserUserIdAndStatus(Long userId, OnboardingStepStatus status);

    /**
     * Count total users who completed onboarding in a date range (for analytics).
     */
    @Query("SELECT COUNT(DISTINCT p.user.userId) FROM UserOnboardingProgress p " +
           "WHERE p.status = 'COMPLETED' AND p.completedAt BETWEEN :from AND :to")
    long countUsersCompletedBetween(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    /**
     * Get completion count per step (for analytics).
     */
    @Query("SELECT p.step.stepId, COUNT(p) FROM UserOnboardingProgress p " +
           "WHERE p.status = :status GROUP BY p.step.stepId")
    List<Object[]> countByStepAndStatus(@Param("status") OnboardingStepStatus status);
}
