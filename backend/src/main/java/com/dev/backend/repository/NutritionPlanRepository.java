package com.dev.backend.repository;

import com.dev.backend.model.entity.NutritionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NutritionPlanRepository extends JpaRepository<NutritionPlan, Long> {

    Optional<NutritionPlan> findByUserUserIdAndIsActiveTrue(Long userId);

    Optional<NutritionPlan> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
