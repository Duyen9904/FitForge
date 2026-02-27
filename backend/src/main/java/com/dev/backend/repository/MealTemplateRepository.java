package com.dev.backend.repository;

import com.dev.backend.model.entity.MealTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MealTemplateRepository extends JpaRepository<MealTemplate, Long> {

    List<MealTemplate> findByNutritionPlanUserUserId(Long userId);

    List<MealTemplate> findByNutritionPlanNutritionPlanId(Long planId);

    Optional<MealTemplate> findByMealTemplateIdAndNutritionPlanUserUserId(Long templateId, Long userId);
}
