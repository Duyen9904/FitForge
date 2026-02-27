package com.dev.backend.service;

import com.dev.backend.model.dto.external.EdamamRecipeResponse;

/**
 * Service for integrating with Edamam Recipe Search API
 * Provides meal recommendations with fallback to generic templates
 */
public interface MealAPIService {

    /**
     * Search recipes by meal type and calorie range
     * Falls back to generic templates if API is unavailable
     * @param mealType meal type (breakfast, lunch, dinner, snack)
     * @param targetCalories target calories for the meal
     * @param proteinPercent protein percentage
     * @param carbsPercent carbs percentage
     * @param fatsPercent fats percentage
     * @return recipe response with matches
     */
    EdamamRecipeResponse searchRecipes(String mealType, int targetCalories, 
                                       float proteinPercent, float carbsPercent, float fatsPercent);

    /**
     * Search recipes with dietary preferences
     * @param mealType meal type (breakfast, lunch, dinner, snack)
     * @param targetCalories target calories for the meal
     * @param diet dietary restriction (e.g., high-protein, low-carb, balanced)
     * @param proteinPercent protein percentage
     * @param carbsPercent carbs percentage
     * @param fatsPercent fats percentage
     * @return recipe response with matches
     */
    EdamamRecipeResponse searchRecipesWithDiet(String mealType, int targetCalories, String diet,
                                                float proteinPercent, float carbsPercent, float fatsPercent);

    /**
     * Create a generic meal template as fallback when API is unavailable
     * @param mealType meal type
     * @param calories target calories
     * @param proteinPercent protein percentage
     * @param carbsPercent carbs percentage
     * @param fatsPercent fats percentage
     * @return generic recipe response
     */
    EdamamRecipeResponse createGenericMealTemplate(String mealType, int calories,
                                                   float proteinPercent, float carbsPercent, float fatsPercent);
}
