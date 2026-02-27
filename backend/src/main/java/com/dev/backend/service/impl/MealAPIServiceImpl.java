package com.dev.backend.service.impl;

import com.dev.backend.client.MealAPIClient;
import com.dev.backend.model.dto.external.EdamamRecipeResponse;
import com.dev.backend.service.MealAPIService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MealAPIServiceImpl implements MealAPIService {

    private final MealAPIClient mealAPIClient;

    @Override
    @Cacheable(value = "recipes", key = "'meal_' + #mealType + '_' + #targetCalories")
    public EdamamRecipeResponse searchRecipes(String mealType, int targetCalories, 
                                              float proteinPercent, float carbsPercent, float fatsPercent) {
        log.info("Searching recipes for mealType: {}, calories: {}", mealType, targetCalories);

        try {
            // Calculate calorie range (±50 calories)
            int minCalories = Math.max(50, targetCalories - 50);
            int maxCalories = targetCalories + 50;

            // Try Edamam API first
            EdamamRecipeResponse response = mealAPIClient.searchRecipes(
                    mealType.toLowerCase(), 
                    minCalories, 
                    maxCalories, 
                    10 // Fetch 10 recipes to have variety
            );

            if (response != null && response.getHits() != null && !response.getHits().isEmpty()) {
                log.info("Found {} recipes from Edamam API for {}", response.getHits().size(), mealType);
                return response;
            }

            // Fallback to generic template
            log.warn("No recipes from Edamam API, creating generic template for {}", mealType);
            return createGenericMealTemplate(mealType, targetCalories, proteinPercent, carbsPercent, fatsPercent);

        } catch (Exception e) {
            log.error("Error searching recipes from Edamam API", e);
            return createGenericMealTemplate(mealType, targetCalories, proteinPercent, carbsPercent, fatsPercent);
        }
    }

    @Override
    @Cacheable(value = "recipes", key = "'meal_diet_' + #mealType + '_' + #targetCalories + '_' + #diet")
    public EdamamRecipeResponse searchRecipesWithDiet(String mealType, int targetCalories, String diet,
                                                      float proteinPercent, float carbsPercent, float fatsPercent) {
        log.info("Searching recipes for mealType: {}, calories: {}, diet: {}", mealType, targetCalories, diet);

        try {
            // Calculate calorie range (±50 calories)
            int minCalories = Math.max(50, targetCalories - 50);
            int maxCalories = targetCalories + 50;

            // Try Edamam API with diet preference
            EdamamRecipeResponse response = mealAPIClient.searchRecipesWithDiet(
                    mealType.toLowerCase(), 
                    minCalories, 
                    maxCalories, 
                    diet,
                    10 // Fetch 10 recipes
            );

            if (response != null && response.getHits() != null && !response.getHits().isEmpty()) {
                log.info("Found {} recipes from Edamam API for {} with diet {}", 
                        response.getHits().size(), mealType, diet);
                return response;
            }

            // Fallback to generic template
            log.warn("No recipes from Edamam API, creating generic template for {} with diet {}", mealType, diet);
            return createGenericMealTemplate(mealType, targetCalories, proteinPercent, carbsPercent, fatsPercent);

        } catch (Exception e) {
            log.error("Error searching recipes with diet from Edamam API", e);
            return createGenericMealTemplate(mealType, targetCalories, proteinPercent, carbsPercent, fatsPercent);
        }
    }

    @Override
    public EdamamRecipeResponse createGenericMealTemplate(String mealType, int calories,
                                                          float proteinPercent, float carbsPercent, float fatsPercent) {
        log.info("Creating generic meal template for {}, {} calories", mealType, calories);

        // Calculate macros from percentages
        float proteinG = (calories * (proteinPercent / 100f)) / 4; // 4 cal per g
        float carbsG = (calories * (carbsPercent / 100f)) / 4; // 4 cal per g
        float fatsG = (calories * (fatsPercent / 100f)) / 9; // 9 cal per g

        // Create generic recipe based on meal type
        EdamamRecipeResponse.Recipe recipe = new EdamamRecipeResponse.Recipe();
        recipe.setUri("generic:" + mealType);
        recipe.setLabel(getGenericMealName(mealType, calories));
        recipe.setSource("Generated Template");
        recipe.setUrl("");
        recipe.setYield(1.0);
        recipe.setCalories(calories);
        recipe.setMealType(List.of(mealType));
        recipe.setIngredientLines(getGenericIngredients(mealType, proteinG, carbsG, fatsG));

        // Set nutrients
        EdamamRecipeResponse.Nutrients nutrients = new EdamamRecipeResponse.Nutrients();
        nutrients.setCalories(createNutrient("Energy", calories, "kcal"));
        nutrients.setProtein(createNutrient("Protein", proteinG, "g"));
        nutrients.setCarbs(createNutrient("Carbs", carbsG, "g"));
        nutrients.setFat(createNutrient("Fat", fatsG, "g"));
        
        recipe.setTotalNutrients(nutrients);
        recipe.setTotalDaily(nutrients);

        // Create hit and response
        EdamamRecipeResponse.RecipeHit hit = new EdamamRecipeResponse.RecipeHit();
        hit.setRecipe(recipe);

        EdamamRecipeResponse response = new EdamamRecipeResponse();
        response.setFrom(0);
        response.setTo(1);
        response.setCount(1);
        response.setHits(List.of(hit));

        return response;
    }

    // Helper: Get generic meal name based on type and calories
    private String getGenericMealName(String mealType, int calories) {
        return switch (mealType.toLowerCase()) {
            case "breakfast" -> calories > 400 ? "Hearty Breakfast Bowl" : "Light Breakfast";
            case "lunch" -> calories > 600 ? "Power Lunch Plate" : "Balanced Lunch";
            case "dinner" -> calories > 600 ? "Complete Dinner" : "Light Dinner";
            case "snack" -> calories > 200 ? "Protein Snack" : "Quick Snack";
            default -> "Balanced Meal";
        };
    }

    // Helper: Generate generic ingredients based on macros
    private List<String> getGenericIngredients(String mealType, float proteinG, float carbsG, float fatsG) {
        List<String> ingredients = new ArrayList<>();

        switch (mealType.toLowerCase()) {
            case "breakfast":
                ingredients.add(String.format("%.0fg eggs or egg whites (protein)", proteinG * 0.15));
                ingredients.add(String.format("%.0fg oats or whole grain toast (carbs)", carbsG * 0.8));
                ingredients.add(String.format("%.0fg avocado or nuts (healthy fats)", fatsG * 0.9));
                ingredients.add("Fresh fruits and vegetables");
                break;
            case "lunch":
                ingredients.add(String.format("%.0fg chicken breast, fish, or tofu (protein)", proteinG * 0.85));
                ingredients.add(String.format("%.0fg brown rice, quinoa, or sweet potato (carbs)", carbsG * 0.75));
                ingredients.add(String.format("%.0fg olive oil or avocado (healthy fats)", fatsG));
                ingredients.add("Mixed vegetables and salad");
                break;
            case "dinner":
                ingredients.add(String.format("%.0fg lean protein (chicken, fish, lean beef, or plant-based)", proteinG * 0.8));
                ingredients.add(String.format("%.0fg vegetables (carbs from fiber-rich sources)", carbsG * 0.7));
                ingredients.add(String.format("%.0fg healthy fats (olive oil, nuts, seeds)", fatsG));
                ingredients.add("Herbs and spices for flavor");
                break;
            case "snack":
                ingredients.add(String.format("%.0fg Greek yogurt or protein shake", proteinG * 0.9));
                ingredients.add(String.format("%.0fg fruit or whole grain crackers", carbsG * 0.8));
                ingredients.add(String.format("%.0fg nuts or nut butter", fatsG * 0.9));
                break;
            default:
                ingredients.add("Balanced combination of protein, carbs, and healthy fats");
                ingredients.add("Vegetables and whole grains");
                ingredients.add("Lean protein source");
        }

        return ingredients;
    }

    // Helper: Create nutrient object
    private EdamamRecipeResponse.Nutrient createNutrient(String label, double quantity, String unit) {
        EdamamRecipeResponse.Nutrient nutrient = new EdamamRecipeResponse.Nutrient();
        nutrient.setLabel(label);
        nutrient.setQuantity(quantity);
        nutrient.setUnit(unit);
        return nutrient;
    }
}
