package com.dev.backend.repository;

import com.dev.backend.model.entity.OnboardingStep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OnboardingStepRepository extends JpaRepository<OnboardingStep, Long> {

    /**
     * Get all active onboarding steps in display order.
     */
    List<OnboardingStep> findByIsActiveTrueOrderByDisplayOrderAsc();

    /**
     * Get all steps (including inactive) in display order for admin.
     */
    List<OnboardingStep> findAllByOrderByDisplayOrderAsc();

    /**
     * Find step by its unique key.
     */
    Optional<OnboardingStep> findByStepKey(String stepKey);

    /**
     * Check if a step key already exists.
     */
    boolean existsByStepKey(String stepKey);

    /**
     * Get maximum display order for new step ordering.
     */
    Optional<OnboardingStep> findTopByOrderByDisplayOrderDesc();
}
