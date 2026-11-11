package com.dev.backend.repository;

import com.dev.backend.model.entity.UserOnboarding;
import com.dev.backend.model.enums.OnboardingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface UserOnboardingRepository extends JpaRepository<UserOnboarding, Long> {

    /**
     * Find the latest onboarding session for a user.
     */
    Optional<UserOnboarding> findFirstByUserUserIdOrderByStartedAtDesc(Long userId);

    /**
     * Find a user's onboarding session for a specific flow.
     */
    Optional<UserOnboarding> findByUserUserIdAndFlowId(Long userId, Long flowId);

    /**
     * Count users who completed onboarding in a date range.
     */
    long countByStatusAndCompletedAtBetween(OnboardingStatus status, LocalDateTime from, LocalDateTime to);

    /**
     * Count users who started onboarding in a date range.
     */
    long countByStartedAtBetween(LocalDateTime from, LocalDateTime to);
}
