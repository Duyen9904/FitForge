package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for Edamam Recipe Search API
 * Maps to the recipe data returned from https://api.edamam.com/api/recipes/v2
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class EdamamRecipeResponse {

    @JsonProperty("from")
    private int from;

    @JsonProperty("to")
    private int to;

    @JsonProperty("count")
    private int count;

    @JsonProperty("hits")
    private List<RecipeHit> hits;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class RecipeHit {
        @JsonProperty("recipe")
        private Recipe recipe;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Recipe {
        @JsonProperty("uri")
        private String uri;

        @JsonProperty("label")
        private String label; // Recipe name

        @JsonProperty("image")
        private String image;

        @JsonProperty("source")
        private String source;

        @JsonProperty("url")
        private String url;

        @JsonProperty("yield")
        private double yield; // Number of servings

        @JsonProperty("calories")
        private double calories;

        @JsonProperty("totalWeight")
        private double totalWeight;

        @JsonProperty("totalTime")
        private double totalTime;

        @JsonProperty("cuisineType")
        private List<String> cuisineType;

        @JsonProperty("mealType")
        private List<String> mealType;

        @JsonProperty("dishType")
        private List<String> dishType;

        @JsonProperty("ingredientLines")
        private List<String> ingredientLines;

        @JsonProperty("ingredients")
        private List<Ingredient> ingredients;

        @JsonProperty("totalNutrients")
        private Nutrients totalNutrients;

        @JsonProperty("totalDaily")
        private Nutrients totalDaily;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Ingredient {
        @JsonProperty("text")
        private String text;

        @JsonProperty("quantity")
        private double quantity;

        @JsonProperty("measure")
        private String measure;

        @JsonProperty("food")
        private String food;

        @JsonProperty("weight")
        private double weight;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Nutrients {
        @JsonProperty("ENERC_KCAL")
        private Nutrient calories;

        @JsonProperty("PROCNT")
        private Nutrient protein;

        @JsonProperty("FAT")
        private Nutrient fat;

        @JsonProperty("CHOCDF")
        private Nutrient carbs;

        @JsonProperty("FIBTG")
        private Nutrient fiber;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Nutrient {
        @JsonProperty("label")
        private String label;

        @JsonProperty("quantity")
        private double quantity;

        @JsonProperty("unit")
        private String unit;
    }
}
