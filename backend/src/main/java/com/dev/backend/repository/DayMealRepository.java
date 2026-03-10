package com.dev.backend.repository;

import com.dev.backend.model.entity.DayMeal;
import com.dev.backend.model.projection.DailyNutritionAggregate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface DayMealRepository extends JpaRepository<DayMeal, Long> {

    List<DayMeal> findByNutritionDayNutritionDayIdOrderByOrderIndexAsc(Long nutritionDayId);

    /**
     * Aggregate nutrition totals from completed DayMeal records for a user
     * whose completedAt timestamp falls within the given day boundaries.
     */
    @Query("SELECT " +
           "COALESCE(SUM(COALESCE(dm.customCalories, dm.mealTemplate.calories)), 0) AS totalCalories, " +
           "COALESCE(SUM(COALESCE(dm.customProteinG, dm.mealTemplate.proteinG)), 0) AS totalProtein, " +
           "COALESCE(SUM(COALESCE(dm.customCarbsG, dm.mealTemplate.carbsG)), 0) AS totalCarbs, " +
           "COALESCE(SUM(COALESCE(dm.customFatsG, dm.mealTemplate.fatsG)), 0) AS totalFats " +
           "FROM DayMeal dm " +
           "WHERE dm.nutritionDay.nutritionPlan.user.userId = :userId " +
           "AND dm.completedAt >= :dayStart AND dm.completedAt < :dayEnd")
    DailyNutritionAggregate getCompletedDayMealSummary(
            @Param("userId") Long userId,
            @Param("dayStart") Instant dayStart,
            @Param("dayEnd") Instant dayEnd);
}
