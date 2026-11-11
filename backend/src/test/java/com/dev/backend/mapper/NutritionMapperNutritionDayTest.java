package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.DayMealResponse;
import com.dev.backend.model.dto.response.MealTemplateResponse;
import com.dev.backend.model.dto.response.NutritionDayResponse;
import com.dev.backend.model.entity.DayMeal;
import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionDay;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.model.enums.MealTemplateSource;
import com.dev.backend.model.enums.MealType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mapstruct.factory.Mappers;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class NutritionMapperNutritionDayTest {

    private NutritionMapper mapper;

    private MealTemplate systemTemplate;
    private MealTemplate userTemplate;

    @BeforeEach
    void setUp() {
        mapper = Mappers.getMapper(NutritionMapper.class);

        systemTemplate = new MealTemplate();
        systemTemplate.setMealTemplateId(1L);
        systemTemplate.setMealName("Grilled Chicken Salad");
        systemTemplate.setMealType("LUNCH");
        systemTemplate.setSource(MealTemplateSource.SYSTEM);
        systemTemplate.setDescription("High protein lunch");
        systemTemplate.setCalories(450);
        systemTemplate.setProteinG(40f);
        systemTemplate.setCarbsG(20f);
        systemTemplate.setFatsG(15f);
        systemTemplate.setRecipeInstructions("Grill chicken. Add salad.");

        userTemplate = new MealTemplate();
        userTemplate.setMealTemplateId(2L);
        userTemplate.setMealName("My Custom Smoothie");
        userTemplate.setMealType("BREAKFAST");
        userTemplate.setSource(MealTemplateSource.USER);
        userTemplate.setCalories(300);
        userTemplate.setProteinG(25f);
        userTemplate.setCarbsG(35f);
        userTemplate.setFatsG(8f);
    }

    @Nested
    @DisplayName("toResponse(MealTemplate) tests")
    class MealTemplateResponseTests {

        @Test
        @DisplayName("Should map system template with source field")
        void toResponse_SystemTemplate() {
            MealTemplateResponse response = mapper.toResponse(systemTemplate);

            assertThat(response.getMealTemplateId()).isEqualTo(1L);
            assertThat(response.getMealName()).isEqualTo("Grilled Chicken Salad");
            assertThat(response.getMealType()).isEqualTo(MealType.LUNCH);
            assertThat(response.getSource()).isEqualTo(MealTemplateSource.SYSTEM);
            assertThat(response.getDescription()).isEqualTo("High protein lunch");
            assertThat(response.getCalories()).isEqualTo(450);
            assertThat(response.getProteinG()).isEqualTo(40f);
            assertThat(response.getRecipeInstructions()).isEqualTo("Grill chicken. Add salad.");
        }

        @Test
        @DisplayName("Should map user-created template with USER source")
        void toResponse_UserTemplate() {
            MealTemplateResponse response = mapper.toResponse(userTemplate);

            assertThat(response.getSource()).isEqualTo(MealTemplateSource.USER);
            assertThat(response.getMealName()).isEqualTo("My Custom Smoothie");
        }

        @Test
        @DisplayName("Should handle null mealType gracefully")
        void toResponse_NullMealType() {
            systemTemplate.setMealType(null);

            MealTemplateResponse response = mapper.toResponse(systemTemplate);

            assertThat(response.getMealType()).isNull();
        }
    }

    @Nested
    @DisplayName("toResponse(DayMeal) tests")
    class DayMealResponseTests {

        @Test
        @DisplayName("Should use template values when no custom overrides")
        void toResponse_NoOverrides() {
            DayMeal dayMeal = new DayMeal();
            dayMeal.setDayMealId(10L);
            dayMeal.setMealTemplate(systemTemplate);
            dayMeal.setMealType(MealType.LUNCH);
            dayMeal.setOrderIndex(1);
            dayMeal.setNotes("Bring extra dressing");

            DayMealResponse response = mapper.toResponse(dayMeal);

            assertThat(response.getDayMealId()).isEqualTo(10L);
            assertThat(response.getMealType()).isEqualTo(MealType.LUNCH);
            assertThat(response.getOrderIndex()).isEqualTo(1);
            assertThat(response.getCalories()).isEqualTo(450);  // from template
            assertThat(response.getProteinG()).isEqualTo(40f);
            assertThat(response.getCarbsG()).isEqualTo(20f);
            assertThat(response.getFatsG()).isEqualTo(15f);
            assertThat(response.getNotes()).isEqualTo("Bring extra dressing");
            assertThat(response.getMealTemplate()).isNotNull();
            assertThat(response.getMealTemplate().getMealName()).isEqualTo("Grilled Chicken Salad");
        }

        @Test
        @DisplayName("Should use custom overrides when provided")
        void toResponse_WithCustomOverrides() {
            DayMeal dayMeal = new DayMeal();
            dayMeal.setDayMealId(11L);
            dayMeal.setMealTemplate(systemTemplate);
            dayMeal.setMealType(MealType.LUNCH);
            dayMeal.setOrderIndex(2);
            // Half portion overrides
            dayMeal.setCustomCalories(225);
            dayMeal.setCustomProteinG(20f);
            dayMeal.setCustomCarbsG(10f);
            dayMeal.setCustomFatsG(7.5f);

            DayMealResponse response = mapper.toResponse(dayMeal);

            assertThat(response.getCalories()).isEqualTo(225);     // custom
            assertThat(response.getProteinG()).isEqualTo(20f);     // custom
            assertThat(response.getCarbsG()).isEqualTo(10f);       // custom
            assertThat(response.getFatsG()).isEqualTo(7.5f);       // custom
            // Template is still included in full
            assertThat(response.getMealTemplate().getCalories()).isEqualTo(450);
        }

        @Test
        @DisplayName("Should mix custom and template values")
        void toResponse_PartialOverrides() {
            DayMeal dayMeal = new DayMeal();
            dayMeal.setDayMealId(12L);
            dayMeal.setMealTemplate(systemTemplate);
            dayMeal.setMealType(MealType.LUNCH);
            dayMeal.setOrderIndex(1);
            // Only override calories
            dayMeal.setCustomCalories(300);

            DayMealResponse response = mapper.toResponse(dayMeal);

            assertThat(response.getCalories()).isEqualTo(300);   // custom
            assertThat(response.getProteinG()).isEqualTo(40f);    // from template
            assertThat(response.getCarbsG()).isEqualTo(20f);      // from template
            assertThat(response.getFatsG()).isEqualTo(15f);        // from template
        }
    }

    @Nested
    @DisplayName("toResponse(NutritionDay) tests")
    class NutritionDayResponseTests {

        @Test
        @DisplayName("Should map day with meals")
        void toResponse_WithMeals() {
            NutritionDay day = new NutritionDay();
            day.setNutritionDayId(100L);
            day.setDayNumber(1);
            day.setDayName("High Protein Day");
            day.setDescription("Focus on protein-rich meals");
            day.setTargetCalories(2200);
            day.setIsRestDay(false);

            DayMeal meal1 = new DayMeal();
            meal1.setDayMealId(10L);
            meal1.setMealTemplate(userTemplate);
            meal1.setMealType(MealType.BREAKFAST);
            meal1.setOrderIndex(0);

            DayMeal meal2 = new DayMeal();
            meal2.setDayMealId(11L);
            meal2.setMealTemplate(systemTemplate);
            meal2.setMealType(MealType.LUNCH);
            meal2.setOrderIndex(1);

            day.setDayMeals(List.of(meal1, meal2));

            NutritionDayResponse response = mapper.toResponse(day);

            assertThat(response.getNutritionDayId()).isEqualTo(100L);
            assertThat(response.getDayNumber()).isEqualTo(1);
            assertThat(response.getDayName()).isEqualTo("High Protein Day");
            assertThat(response.getDescription()).isEqualTo("Focus on protein-rich meals");
            assertThat(response.getTargetCalories()).isEqualTo(2200);
            assertThat(response.getIsRestDay()).isFalse();
            assertThat(response.getMeals()).hasSize(2);
            assertThat(response.getMeals().get(0).getMealType()).isEqualTo(MealType.BREAKFAST);
            assertThat(response.getMeals().get(1).getMealType()).isEqualTo(MealType.LUNCH);
        }

        @Test
        @DisplayName("Should handle day with no meals")
        void toResponse_EmptyMeals() {
            NutritionDay day = new NutritionDay();
            day.setNutritionDayId(101L);
            day.setDayNumber(7);
            day.setDayName("Rest Day");
            day.setIsRestDay(true);
            day.setDayMeals(new ArrayList<>());

            NutritionDayResponse response = mapper.toResponse(day);

            assertThat(response.getIsRestDay()).isTrue();
            assertThat(response.getMeals()).isEmpty();
        }

        @Test
        @DisplayName("Should handle null dayMeals list")
        void toResponse_NullMealsList() {
            NutritionDay day = new NutritionDay();
            day.setNutritionDayId(102L);
            day.setDayNumber(1);
            day.setIsRestDay(false);
            day.setDayMeals(null);

            NutritionDayResponse response = mapper.toResponse(day);

            assertThat(response.getMeals()).isEmpty();
        }
    }
}
