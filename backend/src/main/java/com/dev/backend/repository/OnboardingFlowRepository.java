package com.dev.backend.repository;

import com.dev.backend.model.entity.OnboardingFlow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OnboardingFlowRepository extends JpaRepository<OnboardingFlow, Long> {

    /**
     * Find the latest active onboarding flow.
     */
    Optional<OnboardingFlow> findFirstByIsActiveTrueOrderByVersionDesc();

    /**
     * Find flow by key and version.
     */
    Optional<OnboardingFlow> findByFlowKeyAndVersion(String flowKey, Integer version);
}
