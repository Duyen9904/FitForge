package com.dev.backend.controller;

import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.enums.CompensationType;
import com.dev.backend.model.enums.MealType;
import com.dev.backend.service.NutritionService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NutritionController.class)
class NutritionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private NutritionService nutritionService;

    private NutritionPlanResponse mockPlanResponse;
    private NutritionLogResponse mockLogResponse;
    private DailyNutritionSummaryResponse mockSummary;
    private MealTemplateResponse mockTemplateResponse;

    @BeforeEach
    void setUp() {
        mockPlanResponse = NutritionPlanResponse.builder()
                .nutritionPlanId(1L)
                .planName("Weight Loss Plan")
                .dailyCalorieTarget(2000)
                .proteinPercentage(30.0f)
                .carbsPercentage(40.0f)
                .fatsPercentage(30.0f)
                .proteinGrams(150.0f)
                .carbsGrams(200.0f)
                .fatsGrams(66.7f)
                .cheatMealsPerWeek(2)
                .isActive(true)
                .build();

        mockLogResponse = NutritionLogResponse.builder()
                .nutritionId(1L)
                .logDate(LocalDate.now())
                .mealType(MealType.LUNCH)
                .foodName("Chicken Salad")
                .calories(500)
                .proteinG(40.0f)
                .carbsG(20.0f)
                .fatsG(15.0f)
                .isCheatMeal(false)
                .build();

        mockSummary = DailyNutritionSummaryResponse.builder()
                .date(LocalDate.now())
                .totalCalories(1500)
                .totalProteinG(120.0f)
                .totalCarbsG(150.0f)
                .totalFatsG(50.0f)
                .targetCalories(2000)
                .remainingCalories(500)
                .calorieProgress(75.0f)
                .build();

        mockTemplateResponse = MealTemplateResponse.builder()
                .mealTemplateId(1L)
                .mealName("Protein Shake")
                .mealType(MealType.SNACK)
                .calories(200)
                .proteinG(30.0f)
                .build();
    }

    @Nested
    @DisplayName("POST /api/v1/nutrition/plans")
    class CreateNutritionPlanTests {

        @Test
        @DisplayName("Should create nutrition plan successfully")
        void createNutritionPlan_Success() throws Exception {
            CreateNutritionPlanRequest request = CreateNutritionPlanRequest.builder()
                    .planName("My Diet Plan")
                    .dailyCalorieTarget(2000)
                    .proteinPercentage(30.0f)
                    .carbsPercentage(40.0f)
                    .fatsPercentage(30.0f)
                    .build();

            when(nutritionService.createNutritionPlan(eq(1L), any(CreateNutritionPlanRequest.class)))
                    .thenReturn(mockPlanResponse);

            mockMvc.perform(post("/api/v1/nutrition/plans")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.planName").value("Weight Loss Plan"))
                    .andExpect(jsonPath("$.data.dailyCalorieTarget").value(2000));
        }

        @Test
        @DisplayName("Should return 400 when macros don't sum to 100")
        void createNutritionPlan_InvalidMacros_ReturnsBadRequest() throws Exception {
            CreateNutritionPlanRequest request = CreateNutritionPlanRequest.builder()
                    .planName("My Diet Plan")
                    .dailyCalorieTarget(2000)
                    .proteinPercentage(30.0f)
                    .carbsPercentage(30.0f)  // 30+30+30 = 90, not 100
                    .fatsPercentage(30.0f)
                    .build();

            mockMvc.perform(post("/api/v1/nutrition/plans")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/nutrition/plans/active")
    class GetActivePlanTests {

        @Test
        @DisplayName("Should return active nutrition plan")
        void getActivePlan_Success() throws Exception {
            when(nutritionService.getActivePlan(1L)).thenReturn(mockPlanResponse);

            mockMvc.perform(get("/api/v1/nutrition/plans/active")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.isActive").value(true));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/nutrition/meals")
    class LogMealTests {

        @Test
        @DisplayName("Should log meal successfully")
        void logMeal_Success() throws Exception {
            LogMealRequest request = LogMealRequest.builder()
                    .mealType(MealType.LUNCH)
                    .foodName("Grilled Chicken")
                    .calories(400)
                    .proteinG(35.0f)
                    .logDate(LocalDate.now())
                    .build();

            when(nutritionService.logMeal(eq(1L), any(LogMealRequest.class)))
                    .thenReturn(mockLogResponse);

            mockMvc.perform(post("/api/v1/nutrition/meals")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.foodName").value("Chicken Salad"));
        }

        @Test
        @DisplayName("Should return 400 when calories is negative")
        void logMeal_NegativeCalories_ReturnsBadRequest() throws Exception {
            LogMealRequest request = LogMealRequest.builder()
                    .mealType(MealType.LUNCH)
                    .foodName("Invalid Meal")
                    .calories(-100)
                    .build();

            mockMvc.perform(post("/api/v1/nutrition/meals")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/nutrition/summary")
    class GetDailySummaryTests {

        @Test
        @DisplayName("Should return daily nutrition summary")
        void getDailySummary_Success() throws Exception {
            when(nutritionService.getDailySummary(eq(1L), any())).thenReturn(mockSummary);

            mockMvc.perform(get("/api/v1/nutrition/summary")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .param("date", LocalDate.now().toString()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.totalCalories").value(1500))
                    .andExpect(jsonPath("$.data.remainingCalories").value(500));
        }

        @Test
        @DisplayName("Should handle no-data summary without error")
        void getDailySummary_NoData_Success() throws Exception {
            DailyNutritionSummaryResponse emptySummary = DailyNutritionSummaryResponse.builder()
                    .date(LocalDate.now())
                    .totalCalories(0)
                    .totalProteinG(0f)
                    .totalCarbsG(0f)
                    .totalFatsG(0f)
                    .build();

            when(nutritionService.getDailySummary(eq(1L), any())).thenReturn(emptySummary);

            mockMvc.perform(get("/api/v1/nutrition/summary")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.totalCalories").value(0));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/nutrition/dashboard")
    class GetDashboardTests {

        @Test
        @DisplayName("Should return nutrition dashboard")
        void getDashboard_Success() throws Exception {
            NutritionDashboardResponse dashboard = NutritionDashboardResponse.builder()
                    .todaySummary(mockSummary)
                    .recentMeals(List.of(mockLogResponse))
                    .weeklyCheatMeals(NutritionDashboardResponse.WeeklyCheatMealSummary.builder()
                            .usedThisWeek(1)
                            .allowedPerWeek(2)
                            .remaining(1)
                            .build())
                    .activeCompensations(new ArrayList<>())
                    .build();

            when(nutritionService.getDashboard(1L)).thenReturn(dashboard);

            mockMvc.perform(get("/api/v1/nutrition/dashboard")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.todaySummary.totalCalories").value(1500))
                    .andExpect(jsonPath("$.data.weeklyCheatMeals.remaining").value(1));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/nutrition/cheat-meals/{id}/compensation-options")
    class GetCompensationOptionsTests {

        @Test
        @DisplayName("Should return compensation options")
        void getCompensationOptions_Success() throws Exception {
            List<CompensationActionResponse> options = List.of(
                    CompensationActionResponse.builder()
                            .compensationType(CompensationType.ADD_CARDIO)
                            .actionDescription("Add 50 minutes of cardio")
                            .build(),
                    CompensationActionResponse.builder()
                            .compensationType(CompensationType.REDUCE_CALORIES)
                            .actionDescription("Reduce 200 cal/day for 3 days")
                            .build()
            );

            when(nutritionService.generateCompensationOptions(1L, 1L)).thenReturn(options);

            mockMvc.perform(get("/api/v1/nutrition/cheat-meals/1/compensation-options")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray())
                    .andExpect(jsonPath("$.data.length()").value(2));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/nutrition/cheat-meals/{id}/compensation")
    class SelectCompensationTests {

        @Test
        @DisplayName("Should select compensation strategy")
        void selectCompensation_Success() throws Exception {
            SelectCompensationRequest request = SelectCompensationRequest.builder()
                    .compensationType(CompensationType.ADD_CARDIO)
                    .build();

            CompensationActionResponse response = CompensationActionResponse.builder()
                    .compensationId(1L)
                    .compensationType(CompensationType.ADD_CARDIO)
                    .actionDescription("Add 50 minutes of cardio")
                    .isCompleted(false)
                    .build();

            when(nutritionService.selectCompensation(eq(1L), eq(1L), any(SelectCompensationRequest.class)))
                    .thenReturn(response);

            mockMvc.perform(post("/api/v1/nutrition/cheat-meals/1/compensation")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.compensationType").value("ADD_CARDIO"));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/nutrition/templates")
    class GetMealTemplatesTests {

        @Test
        @DisplayName("Should return meal templates")
        void getMealTemplates_Success() throws Exception {
            when(nutritionService.getMealTemplates()).thenReturn(List.of(mockTemplateResponse));

            mockMvc.perform(get("/api/v1/nutrition/templates")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data[0].mealName").value("Protein Shake"));
        }
    }
}
