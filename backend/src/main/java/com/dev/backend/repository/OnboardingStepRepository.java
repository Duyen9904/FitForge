package com.dev.backend.repository;

import com.dev.backend.model.entity.OnboardingStep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OnboardingStepRepository extends JpaRepository<OnboardingStep, Long> {

    /**
     * Get all steps for a flow in sequence order.
     */
    List<OnboardingStep> findByFlowIdOrderBySequenceAsc(Long flowId);

    /**
     * Get all steps across all flows in sequence order.
     */
    List<OnboardingStep> findAllByOrderBySequenceAsc();

    /**
     * Find step by flow and unique key.
     */
    Optional<OnboardingStep> findByFlowIdAndStepKey(Long flowId, String stepKey);

    /**
     * Check if a step key already exists in a flow.
     */
    boolean existsByFlowIdAndStepKey(Long flowId, String stepKey);

    /**
     * Get maximum sequence number for a flow's steps.
     */
    Optional<OnboardingStep> findTopByFlowIdOrderBySequenceDesc(Long flowId);
}
