package com.dev.backend.model.projection;

import java.time.LocalDate;

/**
 * Projection for per-day nutrition totals used in trend summaries.
 */
public interface DailyNutritionTrendAggregate {

    LocalDate getLogDate();

    Number getTotalCalories();

    Number getTotalProtein();

    Number getTotalCarbs();

    Number getTotalFats();
}

