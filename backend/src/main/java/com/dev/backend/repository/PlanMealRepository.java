package com.dev.backend.repository;

import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.model.entity.PlanMeal;
import com.dev.backend.model.enums.PlanMealStatus;
import com.dev.backend.model.projection.DailyNutritionAggregate;
import com.dev.backend.model.projection.DailyNutritionTrendAggregate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dev.backend.model.enums.MealType;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface PlanMealRepository extends JpaRepository<PlanMeal, Long> {

    // ── Lookup by user + date + meal type (for duplicate detection) ──────

    List<PlanMeal> findByUserUserIdAndScheduledDateAndMealTypeAndStatusNot(
            Long userId, LocalDate date, MealType mealType, PlanMealStatus excludedStatus);

    // ── Lookup by user + date ──────────────────────────────────────────

    List<PlanMeal> findByUserUserIdAndScheduledDate(Long userId, LocalDate date);

    List<PlanMeal> findByUserUserIdAndScheduledDateOrderByMealTimeAsc(Long userId, LocalDate date);

    @Query("SELECT p FROM PlanMeal p LEFT JOIN FETCH p.mealTemplate " +
           "WHERE p.user.userId = :userId AND p.scheduledDate = :date AND p.status <> :excludedStatus " +
           "ORDER BY p.mealTime ASC")
    List<PlanMeal> findByUserUserIdAndScheduledDateAndStatusNotOrderByMealTimeAsc(
            @Param("userId") Long userId, @Param("date") LocalDate date,
            @Param("excludedStatus") PlanMealStatus excludedStatus);

    Page<PlanMeal> findByUserUserIdOrderByScheduledDateDescMealTimeDesc(Long userId, Pageable pageable);

    // ── Lookup by plan + date ──────────────────────────────────────────

    List<PlanMeal> findByNutritionPlanAndScheduledDate(NutritionPlan plan, LocalDate date);

    List<PlanMeal> findByNutritionPlanAndScheduledDateBetween(
            NutritionPlan plan, LocalDate start, LocalDate end);

    List<PlanMeal> findByNutritionPlanNutritionPlanIdAndScheduledDate(
            Long planId, LocalDate date);

    // ── Lookup by status ───────────────────────────────────────────────

    List<PlanMeal> findByUserUserIdAndScheduledDateAndStatus(
            Long userId, LocalDate date, PlanMealStatus status);

    // ── Daily summary (COMPLETED meals only) ───────────────────────────

    @Query("SELECT " +
           "COALESCE(SUM(p.calories), 0) AS totalCalories, " +
           "COALESCE(SUM(p.proteinG), 0) AS totalProtein, " +
           "COALESCE(SUM(p.carbsG), 0) AS totalCarbs, " +
           "COALESCE(SUM(p.fatsG), 0) AS totalFats " +
           "FROM PlanMeal p WHERE p.user.userId = :userId AND p.scheduledDate = :date " +
           "AND p.status = 'COMPLETED'")
    DailyNutritionAggregate getDailySummary(@Param("userId") Long userId,
                                            @Param("date") LocalDate date);

    // ── Weekly/range totals (COMPLETED meals only) ─────────────────────

    @Query("SELECT " +
           "p.scheduledDate AS logDate, " +
           "COALESCE(SUM(p.calories), 0) AS totalCalories, " +
           "COALESCE(SUM(p.proteinG), 0) AS totalProtein, " +
           "COALESCE(SUM(p.carbsG), 0) AS totalCarbs, " +
           "COALESCE(SUM(p.fatsG), 0) AS totalFats " +
           "FROM PlanMeal p WHERE p.user.userId = :userId " +
           "AND p.scheduledDate BETWEEN :start AND :end " +
           "AND p.status = 'COMPLETED' " +
           "GROUP BY p.scheduledDate ORDER BY p.scheduledDate")
    List<DailyNutritionTrendAggregate> getDailyTotals(@Param("userId") Long userId,
                                                      @Param("start") LocalDate start,
                                                      @Param("end") LocalDate end);

    // ── Cheat meal counts ──────────────────────────────────────────────

    long countByUserUserIdAndScheduledDateAndIsCheatMealTrueAndStatus(
            Long userId, LocalDate date, PlanMealStatus status);

    @Query("SELECT COUNT(DISTINCT p.scheduledDate) FROM PlanMeal p " +
           "WHERE p.user.userId = :userId AND p.isCheatMeal = true " +
           "AND p.scheduledDate BETWEEN :start AND :end " +
           "AND p.status = 'COMPLETED'")
    long countCheatDaysBetween(@Param("userId") Long userId,
                               @Param("start") LocalDate start,
                               @Param("end") LocalDate end);

    @Query("SELECT COUNT(DISTINCT p.scheduledDate) FROM PlanMeal p " +
           "WHERE p.user.userId = :userId " +
           "AND p.scheduledDate BETWEEN :start AND :end " +
           "AND p.status = 'COMPLETED'")
    long countDistinctLogDatesByUserAndDateRange(@Param("userId") Long userId,
                                                  @Param("start") LocalDate start,
                                                  @Param("end") LocalDate end);
}
