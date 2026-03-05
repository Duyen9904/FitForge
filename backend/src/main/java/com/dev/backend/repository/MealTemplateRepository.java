package com.dev.backend.repository;

import com.dev.backend.model.entity.MealTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MealTemplateRepository extends JpaRepository<MealTemplate, Long> {

    List<MealTemplate> findByMealType(String mealType);
}
