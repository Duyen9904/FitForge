package com.dev.backend.service.impl;

import com.dev.backend.model.dto.external.EdamamRecipeResponse;
import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.service.MealAPIService;
import com.dev.backend.service.MealTemplateGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MealTemplateGeneratorImpl implements MealTemplateGenerator {

    private final MealAPIService mealAPIService;

    @Override
    public List<MealTemplate> generateDayMeals(NutritionPlan plan, int dayNumber) {
        log.info("Generating meal templates for plan {}, day {}", plan.getNutritionPlanId(), dayNumber);

        List<MealTemplate> meals = new ArrayList<>();

        // Generate 3 main meals: Breakfast, Lunch, Dinner
        meals.add(generateMeal(plan, "BREAKFAST", dayNumber));
        meals.add(generateMeal(plan, "LUNCH", dayNumber));
        meals.add(generateMeal(plan, "DINNER", dayNumber));

        return meals;
    }

    @Override
    public MealTemplate regenerateMeal(NutritionPlan plan, String mealType, int dayNumber) {
        log.info("Regenerating meal {} for plan {}, day {}", mealType, plan.getNutritionPlanId(), dayNumber);
        return generateMeal(plan, mealType, dayNumber);
    }

    // Helper: Generate a single meal
    private MealTemplate generateMeal(NutritionPlan plan, String mealType, int dayNumber) {
        log.info("Generating {} for day {}", mealType, dayNumber);

        // Calculate target calories for this meal
        int dailyCalorieTarget = plan.getDailyCalorieTarget() != null ? plan.getDailyCalorieTarget() : 2000;
        int mealCalories = calculateMealCalories(mealType, dailyCalorieTarget);

        // Get macro percentages
        float proteinPercent = plan.getProteinPercentage() != null ? plan.getProteinPercentage() : 30f;
        float carbsPercent = plan.getCarbsPercentage() != null ? plan.getCarbsPercentage() : 40f;
        float fatsPercent = plan.getFatsPercentage() != null ? plan.getFatsPercentage() : 30f;

        // Determine dietary preference based on goal
        String diet = determineDiet(plan, proteinPercent, carbsPercent);

        // Search for recipes from API
        EdamamRecipeResponse response = mealAPIService.searchRecipesWithDiet(
                mealType.toLowerCase(),
                mealCalories,
                diet,
                proteinPercent,
                carbsPercent,
                fatsPercent
        );

        // Select a recipe (vary by day number to get different meals)
        EdamamRecipeResponse.Recipe recipe = selectRecipe(response, dayNumber);

        // Create meal template
        return createMealTemplate(plan, mealType, recipe, mealCalories, proteinPercent, carbsPercent, fatsPercent);
    }

    // Helper: Calculate calories for a meal based on type
    private int calculateMealCalories(String mealType, int dailyCalories) {
        return switch (mealType.toUpperCase()) {
            case "BREAKFAST" -> (int) (dailyCalories * 0.25); // 25%
            case "LUNCH" -> (int) (dailyCalories * 0.35); // 35%
            case "DINNER" -> (int) (dailyCalories * 0.30); // 30%
            case "SNACK" -> (int) (dailyCalories * 0.10); // 10%
            default -> (int) (dailyCalories * 0.30);
        };
    }

    // Helper: Determine dietary preference
    private String determineDiet(NutritionPlan plan, float proteinPercent, float carbsPercent) {
        String goalName = plan.getGoal() != null ? plan.getGoal().getGoalName() : "";
        String goalUpper = goalName.toUpperCase();

        if (goalUpper.contains("MUSCLE") || goalUpper.contains("GAIN")) {
            return "high-protein";
        } else if (goalUpper.contains("FAT") || goalUpper.contains("LOSS")) {
            if (carbsPercent < 35) {
                return "low-carb";
            }
            return "high-protein";
        } else if (proteinPercent >= 35) {
            return "high-protein";
        } else if (carbsPercent <= 30) {
            return "low-carb";
        }

        return "balanced";
    }

    // Helper: Select a recipe from response (vary by day to get different meals)
    private EdamamRecipeResponse.Recipe selectRecipe(EdamamRecipeResponse response, int dayNumber) {
        if (response == null || response.getHits() == null || response.getHits().isEmpty()) {
            log.warn("No recipes found in response");
            return null;
        }

        List<EdamamRecipeResponse.RecipeHit> hits = response.getHits();
        
        // Select recipe based on day number to provide variety
        int index = (dayNumber - 1) % hits.size();
        return hits.get(index).getRecipe();
    }

    // Helper: Create MealTemplate entity from recipe
    private MealTemplate createMealTemplate(NutritionPlan plan, String mealType, 
                                           EdamamRecipeResponse.Recipe recipe,
                                           int targetCalories, float proteinPercent, 
                                           float carbsPercent, float fatsPercent) {
        MealTemplate template = new MealTemplate();
        template.setNutritionPlan(plan);
        template.setMealType(mealType);

        if (recipe != null) {
            // Use recipe from API
            template.setMealName(recipe.getLabel());
            template.setCalories((int) recipe.getCalories());
            
            // Extract macros from recipe
            if (recipe.getTotalNutrients() != null) {
                EdamamRecipeResponse.Nutrients nutrients = recipe.getTotalNutrients();
                
                if (nutrients.getProtein() != null) {
                    template.setProteinG((float) nutrients.getProtein().getQuantity());
                }
                if (nutrients.getCarbs() != null) {
                    template.setCarbsG((float) nutrients.getCarbs().getQuantity());
                }
                if (nutrients.getFat() != null) {
                    template.setFatsG((float) nutrients.getFat().getQuantity());
                }
            }

            // Build recipe instructions
            StringBuilder instructions = new StringBuilder();
            
            if (recipe.getSource() != null) {
                instructions.append("Source: ").append(recipe.getSource()).append("\n\n");
            }
            
            if (recipe.getIngredientLines() != null && !recipe.getIngredientLines().isEmpty()) {
                instructions.append("Ingredients:\n");
                for (String ingredient : recipe.getIngredientLines()) {
                    instructions.append("- ").append(ingredient).append("\n");
                }
                instructions.append("\n");
            }
            
            if (recipe.getUrl() != null && !recipe.getUrl().isEmpty()) {
                instructions.append("Full recipe: ").append(recipe.getUrl()).append("\n");
            }
            
            template.setRecipeInstructions(instructions.toString());
            
            template.setDescription(String.format("A %s recipe with approximately %d calories",
                    mealType.toLowerCase(), template.getCalories()));
        } else {
            // Fallback: create generic template
            template.setMealName(getGenericMealName(mealType));
            template.setCalories(targetCalories);
            
            // Calculate macros from percentages
            float proteinG = (targetCalories * (proteinPercent / 100f)) / 4; // 4 cal per g
            float carbsG = (targetCalories * (carbsPercent / 100f)) / 4; // 4 cal per g
            float fatsG = (targetCalories * (fatsPercent / 100f)) / 9; // 9 cal per g
            
            template.setProteinG(proteinG);
            template.setCarbsG(carbsG);
            template.setFatsG(fatsG);
            
            template.setRecipeInstructions(getGenericRecipeInstructions(mealType, proteinG, carbsG, fatsG));
            template.setDescription(String.format("A balanced %s with %d calories, %.1fg protein, %.1fg carbs, %.1fg fat",
                    mealType.toLowerCase(), targetCalories, proteinG, carbsG, fatsG));
        }

        return template;
    }

    // Helper: Get generic meal name
    private String getGenericMealName(String mealType) {
        return switch (mealType.toUpperCase()) {
            case "BREAKFAST" -> "Protein-Packed Breakfast";
            case "LUNCH" -> "Balanced Lunch Plate";
            case "DINNER" -> "Complete Dinner Meal";
            case "SNACK" -> "Healthy Snack";
            default -> "Balanced Meal";
        };
    }

    // Helper: Get generic recipe instructions
    private String getGenericRecipeInstructions(String mealType, float proteinG, float carbsG, float fatsG) {
        StringBuilder instructions = new StringBuilder();
        
        instructions.append("Suggested Ingredients:\n\n");
        
        switch (mealType.toUpperCase()) {
            case "BREAKFAST":
                instructions.append(String.format("- %.0fg eggs or egg whites\n", proteinG * 0.15));
                instructions.append(String.format("- %.0fg oats, whole grain bread, or sweet potato\n", carbsG * 0.8));
                instructions.append(String.format("- %.0fg avocado, nuts, or nut butter\n", fatsG * 0.9));
                instructions.append("- Fresh fruits (berries, banana)\n");
                instructions.append("- Optional: Greek yogurt, protein powder\n\n");
                instructions.append("Instructions:\n");
                instructions.append("1. Cook eggs to your preference (scrambled, fried, or boiled)\n");
                instructions.append("2. Prepare carb source (toast, cook oats, or heat sweet potato)\n");
                instructions.append("3. Add healthy fats (slice avocado or add nut butter)\n");
                instructions.append("4. Serve with fresh fruits on the side\n");
                break;
                
            case "LUNCH":
                instructions.append(String.format("- %.0fg chicken breast, fish, tofu, or lean meat\n", proteinG * 0.85));
                instructions.append(String.format("- %.0fg brown rice, quinoa, or whole grain pasta\n", carbsG * 0.75));
                instructions.append(String.format("- %.0fg olive oil or avocado\n", fatsG));
                instructions.append("- Mixed vegetables (2-3 cups)\n");
                instructions.append("- Fresh salad greens\n\n");
                instructions.append("Instructions:\n");
                instructions.append("1. Season and grill/bake protein source (375°F for 20-25 min)\n");
                instructions.append("2. Cook grains according to package directions\n");
                instructions.append("3. Sauté or steam vegetables\n");
                instructions.append("4. Drizzle with olive oil and seasonings\n");
                instructions.append("5. Assemble on plate with salad on the side\n");
                break;
                
            case "DINNER":
                instructions.append(String.format("- %.0fg lean protein (chicken, fish, turkey, or plant-based)\n", proteinG * 0.8));
                instructions.append(String.format("- %.0fg vegetables (broccoli, asparagus, Brussels sprouts)\n", carbsG * 0.7));
                instructions.append(String.format("- %.0fg healthy fats (olive oil, nuts, seeds)\n", fatsG));
                instructions.append("- Herbs and spices for flavor\n");
                instructions.append("- Optional: small serving of whole grains\n\n");
                instructions.append("Instructions:\n");
                instructions.append("1. Season protein with herbs and spices\n");
                instructions.append("2. Grill, bake, or pan-sear protein (internal temp: 165°F for poultry, 145°F for fish)\n");
                instructions.append("3. Roast or steam vegetables (season with salt, pepper, garlic)\n");
                instructions.append("4. Drizzle with olive oil or add nuts/seeds\n");
                instructions.append("5. Plate and enjoy\n");
                break;
                
            case "SNACK":
                instructions.append(String.format("- %.0fg Greek yogurt or protein shake\n", proteinG * 0.9));
                instructions.append(String.format("- %.0fg fruit, whole grain crackers, or rice cakes\n", carbsG * 0.8));
                instructions.append(String.format("- %.0fg almonds, walnuts, or peanut butter\n", fatsG * 0.9));
                instructions.append("\nQuick assembly: Mix yogurt with fruit and nuts, or spread nut butter on crackers.\n");
                break;
                
            default:
                instructions.append("Create a balanced meal with:\n");
                instructions.append("- Lean protein source\n");
                instructions.append("- Complex carbohydrates\n");
                instructions.append("- Healthy fats\n");
                instructions.append("- Plenty of vegetables\n");
        }
        
        instructions.append("\nTip: Adjust portions to match your calorie and macro targets. ");
        instructions.append("Meal prep in advance for convenience.");
        
        return instructions.toString();
    }
}
