package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.NutritionMapper;
import com.dev.backend.model.dto.response.DayMealResponse;
import com.dev.backend.model.dto.response.MealTemplateResponse;
import com.dev.backend.model.dto.response.NutritionDayResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.MealTemplateSource;
import com.dev.backend.model.enums.MealType;
import com.dev.backend.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NutritionServiceImplNutritionDayTest {

    @Mock
    private NutritionPlanRepository planRepository;
    @Mock
    private PlanMealRepository planMealRepository;
    @Mock
    private CheatMealLogRepository cheatMealLogRepository;
    @Mock
    private MealTemplateRepository templateRepository;
    @Mock
    private CompensationActionRepository compensationRepository;
    @Mock
    private NutritionDayRepository nutritionDayRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private GoalRepository goalRepository;

    @Spy
    private NutritionMapper mapper = new NutritionMapper();

    @InjectMocks
    private NutritionServiceImpl nutritionService;

    private User testUser;
    private NutritionPlan testPlan;
    private MealTemplate template1;
    private MealTemplate template2;
    private NutritionDay testDay;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1L);

        testPlan = new NutritionPlan();
        testPlan.setNutritionPlanId(10L);
        testPlan.setUser(testUser);
        testPlan.setPlanName("Muscle Gain Plan");
        testPlan.setDailyCalorieTarget(2500);
        testPlan.setIsActive(true);

        template1 = new MealTemplate();
        template1.setMealTemplateId(100L);
        template1.setMealName("Oatmeal with Berries");
        template1.setMealType("BREAKFAST");
        template1.setSource(MealTemplateSource.SYSTEM);
        template1.setCalories(350);
        template1.setProteinG(12f);
        template1.setCarbsG(55f);
        template1.setFatsG(8f);

        template2 = new MealTemplate();
        template2.setMealTemplateId(101L);
        template2.setMealName("Grilled Chicken Wrap");
        template2.setMealType("LUNCH");
        template2.setSource(MealTemplateSource.SYSTEM);
        template2.setCalories(520);
        template2.setProteinG(42f);
        template2.setCarbsG(40f);
        template2.setFatsG(18f);

        DayMeal meal1 = new DayMeal();
        meal1.setDayMealId(200L);
        meal1.setMealTemplate(template1);
        meal1.setMealType(MealType.BREAKFAST);
        meal1.setOrderIndex(0);

        DayMeal meal2 = new DayMeal();
        meal2.setDayMealId(201L);
        meal2.setMealTemplate(template2);
        meal2.setMealType(MealType.LUNCH);
        meal2.setOrderIndex(1);

        testDay = new NutritionDay();
        testDay.setNutritionDayId(50L);
        testDay.setNutritionPlan(testPlan);
        testDay.setDayNumber(1);
        testDay.setDayName("High Protein Day");
        testDay.setIsRestDay(false);
        testDay.setDayMeals(List.of(meal1, meal2));
    }

    @Nested
    @DisplayName("getPlanDays tests")
    class GetPlanDaysTests {

        @Test
        @DisplayName("Should return all days with nested meals for a plan")
        void getPlanDays_Success() {
            // Arrange
            NutritionDay day2 = new NutritionDay();
            day2.setNutritionDayId(51L);
            day2.setNutritionPlan(testPlan);
            day2.setDayNumber(2);
            day2.setDayName("Rest Day");
            day2.setIsRestDay(true);
            day2.setDayMeals(new ArrayList<>());

            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));
            when(nutritionDayRepository.findByPlanIdWithMeals(10L))
                    .thenReturn(List.of(testDay, day2));

            // Act
            List<NutritionDayResponse> result = nutritionService.getPlanDays(1L, 10L);

            // Assert
            assertThat(result).hasSize(2);

            NutritionDayResponse firstDay = result.get(0);
            assertThat(firstDay.getDayNumber()).isEqualTo(1);
            assertThat(firstDay.getDayName()).isEqualTo("High Protein Day");
            assertThat(firstDay.getIsRestDay()).isFalse();
            assertThat(firstDay.getMeals()).hasSize(2);

            DayMealResponse breakfast = firstDay.getMeals().get(0);
            assertThat(breakfast.getMealType()).isEqualTo(MealType.BREAKFAST);
            assertThat(breakfast.getCalories()).isEqualTo(350);
            assertThat(breakfast.getMealTemplate()).isNotNull();
            assertThat(breakfast.getMealTemplate().getMealName()).isEqualTo("Oatmeal with Berries");
            assertThat(breakfast.getMealTemplate().getSource()).isEqualTo(MealTemplateSource.SYSTEM);

            DayMealResponse lunch = firstDay.getMeals().get(1);
            assertThat(lunch.getMealType()).isEqualTo(MealType.LUNCH);
            assertThat(lunch.getCalories()).isEqualTo(520);

            NutritionDayResponse secondDay = result.get(1);
            assertThat(secondDay.getDayNumber()).isEqualTo(2);
            assertThat(secondDay.getIsRestDay()).isTrue();
            assertThat(secondDay.getMeals()).isEmpty();
        }

        @Test
        @DisplayName("Should return empty list when plan has no days")
        void getPlanDays_NoDays() {
            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));
            when(nutritionDayRepository.findByPlanIdWithMeals(10L))
                    .thenReturn(List.of());

            List<NutritionDayResponse> result = nutritionService.getPlanDays(1L, 10L);

            assertThat(result).isEmpty();
        }

        @Test
        @DisplayName("Should throw exception when plan not found")
        void getPlanDays_PlanNotFound() {
            when(planRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> nutritionService.getPlanDays(1L, 999L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Nutrition plan not found");
        }

        @Test
        @DisplayName("Should throw exception when plan belongs to different user")
        void getPlanDays_WrongUser() {
            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));

            assertThatThrownBy(() -> nutritionService.getPlanDays(999L, 10L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Nutrition plan not found");
        }
    }

    @Nested
    @DisplayName("getPlanDay tests")
    class GetPlanDayTests {

        @Test
        @DisplayName("Should return specific day with meals")
        void getPlanDay_Success() {
            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));
            when(nutritionDayRepository.findByPlanIdAndDayNumberWithMeals(10L, 1))
                    .thenReturn(Optional.of(testDay));

            NutritionDayResponse result = nutritionService.getPlanDay(1L, 10L, 1);

            assertThat(result.getNutritionDayId()).isEqualTo(50L);
            assertThat(result.getDayNumber()).isEqualTo(1);
            assertThat(result.getDayName()).isEqualTo("High Protein Day");
            assertThat(result.getMeals()).hasSize(2);
        }

        @Test
        @DisplayName("Should throw exception when day not found")
        void getPlanDay_DayNotFound() {
            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));
            when(nutritionDayRepository.findByPlanIdAndDayNumberWithMeals(10L, 99))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> nutritionService.getPlanDay(1L, 10L, 99))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Nutrition day not found");
        }

        @Test
        @DisplayName("Should throw exception when plan not found")
        void getPlanDay_PlanNotFound() {
            when(planRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> nutritionService.getPlanDay(1L, 999L, 1))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Nutrition plan not found");
        }

        @Test
        @DisplayName("Should throw exception when plan belongs to different user")
        void getPlanDay_WrongUser() {
            when(planRepository.findById(10L)).thenReturn(Optional.of(testPlan));

            assertThatThrownBy(() -> nutritionService.getPlanDay(999L, 10L, 1))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Nutrition plan not found");
        }
    }
}
