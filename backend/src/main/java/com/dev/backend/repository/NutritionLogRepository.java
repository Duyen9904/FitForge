package com.dev.backend.repository;

import com.dev.backend.model.entity.NutritionLog;
import com.dev.backend.model.projection.DailyNutritionAggregate;
import com.dev.backend.model.projection.DailyNutritionTrendAggregate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface NutritionLogRepository extends JpaRepository<NutritionLog, Long> {

    List<NutritionLog> findByUserUserIdAndLogDate(Long userId, LocalDate date);

    List<NutritionLog> findByUserUserIdAndLogDateOrderByMealTimeAsc(Long userId, LocalDate date);

    Page<NutritionLog> findByUserUserIdOrderByLogDateDescMealTimeDesc(Long userId, Pageable pageable);

    @Query("SELECT " +
           "COALESCE(SUM(n.calories), 0) AS totalCalories, " +
           "COALESCE(SUM(n.proteinG), 0) AS totalProtein, " +
           "COALESCE(SUM(n.carbsG), 0) AS totalCarbs, " +
           "COALESCE(SUM(n.fatsG), 0) AS totalFats " +
           "FROM NutritionLog n WHERE n.user.userId = :userId AND n.logDate = :date")
    DailyNutritionAggregate getDailySummary(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Query("SELECT " +
           "n.logDate AS logDate, " +
           "COALESCE(SUM(n.calories), 0) AS totalCalories, " +
           "COALESCE(SUM(n.proteinG), 0) AS totalProtein, " +
           "COALESCE(SUM(n.carbsG), 0) AS totalCarbs, " +
           "COALESCE(SUM(n.fatsG), 0) AS totalFats " +
           "FROM NutritionLog n WHERE n.user.userId = :userId AND n.logDate BETWEEN :start AND :end " +
           "GROUP BY n.logDate ORDER BY n.logDate")
    List<DailyNutritionTrendAggregate> getDailyTotals(@Param("userId") Long userId,
                                                      @Param("start") LocalDate start,
                                                      @Param("end") LocalDate end);

    long countByUserUserIdAndLogDateAndIsCheatMealTrue(Long userId, LocalDate date);

    @Query("SELECT COUNT(DISTINCT n.logDate) FROM NutritionLog n " +
           "WHERE n.user.userId = :userId AND n.isCheatMeal = true AND n.logDate BETWEEN :start AND :end")
    long countCheatDaysBetween(@Param("userId") Long userId,
                               @Param("start") LocalDate start,
                               @Param("end") LocalDate end);

    @Query("SELECT COUNT(DISTINCT n.logDate) FROM NutritionLog n " +
           "WHERE n.user.userId = :userId AND n.logDate BETWEEN :start AND :end")
    long countDistinctLogDatesByUserAndDateRange(@Param("userId") Long userId,
                                                  @Param("start") LocalDate start,
                                                  @Param("end") LocalDate end);
}
