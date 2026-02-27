package com.dev.backend.repository;

import com.dev.backend.model.entity.MeasurementGoal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MeasurementGoalRepository extends JpaRepository<MeasurementGoal, Long> {

    Optional<MeasurementGoal> findByUserUserIdAndIsActiveTrue(Long userId);

    Optional<MeasurementGoal> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
