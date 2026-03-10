package com.dev.backend.repository;

import com.dev.backend.model.entity.NutritionDay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NutritionDayRepository extends JpaRepository<NutritionDay, Long> {

    @Query("SELECT d FROM NutritionDay d LEFT JOIN FETCH d.dayMeals dm " +
           "LEFT JOIN FETCH dm.mealTemplate " +
           "WHERE d.nutritionPlan.nutritionPlanId = :planId " +
           "ORDER BY d.dayNumber ASC")
    List<NutritionDay> findByPlanIdWithMeals(@Param("planId") Long planId);

    @Query("SELECT d FROM NutritionDay d LEFT JOIN FETCH d.dayMeals dm " +
           "LEFT JOIN FETCH dm.mealTemplate " +
           "WHERE d.nutritionPlan.nutritionPlanId = :planId AND d.dayNumber = :dayNumber")
    Optional<NutritionDay> findByPlanIdAndDayNumberWithMeals(@Param("planId") Long planId,
                                                             @Param("dayNumber") int dayNumber);
}
