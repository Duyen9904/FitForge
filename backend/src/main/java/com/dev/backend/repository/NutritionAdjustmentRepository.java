package com.dev.backend.repository;

import com.dev.backend.model.entity.NutritionAdjustment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repository for nutrition adjustments (UC-11.3)
 */
@Repository
public interface NutritionAdjustmentRepository extends JpaRepository<NutritionAdjustment, Long> {

    /**
     * Find active adjustments for a nutrition plan
     */
    List<NutritionAdjustment> findByNutritionPlanNutritionPlanIdAndIsActiveTrue(Long nutritionPlanId);

    /**
     * Find adjustments by compensation action
     */
    List<NutritionAdjustment> findByCompensationActionCompensationId(Long compensationId);

    /**
     * Find adjustments valid for a specific date
     */
    @Query("SELECT na FROM NutritionAdjustment na WHERE na.nutritionPlan.nutritionPlanId = :nutritionPlanId AND na.isActive = true AND na.adjustmentDate <= :date AND (na.validUntilDate IS NULL OR na.validUntilDate >= :date)")
    List<NutritionAdjustment> findActiveForDate(@Param("nutritionPlanId") Long nutritionPlanId, @Param("date") LocalDate date);

    /**
     * Find expired adjustments that need to be deactivated
     */
    @Query("SELECT na FROM NutritionAdjustment na WHERE na.isActive = true AND na.validUntilDate < :today")
    List<NutritionAdjustment> findExpiredAdjustments(@Param("today") LocalDate today);

    /**
     * Get total calorie adjustment for a date
     */
    @Query("SELECT COALESCE(SUM(na.calorieAdjustment), 0) FROM NutritionAdjustment na WHERE na.nutritionPlan.nutritionPlanId = :nutritionPlanId AND na.isActive = true AND na.adjustmentDate <= :date AND (na.validUntilDate IS NULL OR na.validUntilDate >= :date)")
    Integer getTotalCalorieAdjustmentForDate(@Param("nutritionPlanId") Long nutritionPlanId, @Param("date") LocalDate date);
}
