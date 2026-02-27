package com.dev.backend.model.projection;

/**
 * Projection for aggregated daily nutrition totals.
 *
 * Backed by the `NutritionLogRepository.getDailySummary` query.
 */
public interface DailyNutritionAggregate {

    Number getTotalCalories();

    Number getTotalProtein();

    Number getTotalCarbs();

    Number getTotalFats();
}

