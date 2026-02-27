package com.dev.backend.repository;

import com.dev.backend.model.entity.OnboardingOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OnboardingOptionRepository extends JpaRepository<OnboardingOption, Long> {

    /**
     * Get all active options for a step in display order.
     */
    List<OnboardingOption> findByStepStepIdAndIsActiveTrueOrderByDisplayOrderAsc(Long stepId);

    /**
     * Get all options for a step (including inactive) for admin.
     */
    List<OnboardingOption> findByStepStepIdOrderByDisplayOrderAsc(Long stepId);

    /**
     * Check if option key exists for a step.
     */
    boolean existsByStepStepIdAndOptionKey(Long stepId, String optionKey);

    /**
     * Find option by step and key.
     */
    Optional<OnboardingOption> findByStepStepIdAndOptionKey(Long stepId, String optionKey);

    /**
     * Get maximum display order for a step's options.
     */
    Optional<OnboardingOption> findTopByStepStepIdOrderByDisplayOrderDesc(Long stepId);
}
