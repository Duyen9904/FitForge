package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.NutritionMapper;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.projection.DailyNutritionAggregate;
import com.dev.backend.model.enums.CompensationType;
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

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NutritionServiceImplTest {

    @Mock
    private NutritionPlanRepository planRepository;

    @Mock
    private NutritionLogRepository logRepository;

    @Mock
    private CheatMealLogRepository cheatMealLogRepository;

    @Mock
    private MealTemplateRepository templateRepository;

    @Mock
    private CompensationActionRepository compensationRepository;

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
    private NutritionLog testLog;
    private MealTemplate testTemplate;
    private CheatMealLog testCheatLog;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");

        testPlan = new NutritionPlan();
        testPlan.setNutritionPlanId(1L);
        testPlan.setUser(testUser);
        testPlan.setPlanName("Weight Loss Plan");
        testPlan.setDailyCalorieTarget(2000);
        testPlan.setProteinPercentage(30.0f);
        testPlan.setCarbsPercentage(40.0f);
        testPlan.setFatsPercentage(30.0f);
        testPlan.setCheatMealsPerWeek(2);
        testPlan.setAutoAdjustEnabled(false);
        testPlan.setIsActive(true);

        testLog = new NutritionLog();
        testLog.setNutritionId(1L);
        testLog.setUser(testUser);
        testLog.setLogDate(LocalDate.now());
        testLog.setMealType("LUNCH");
        testLog.setFoodName("Chicken Salad");
        testLog.setCalories(500);
        testLog.setProteinG(40.0f);
        testLog.setCarbsG(20.0f);
        testLog.setFatsG(15.0f);
        testLog.setIsCheatMeal(false);

        testTemplate = new MealTemplate();
        testTemplate.setMealTemplateId(1L);
        testTemplate.setNutritionPlan(testPlan);
        testTemplate.setMealName("Protein Shake");
        testTemplate.setMealType("SNACK");
        testTemplate.setCalories(200);
        testTemplate.setProteinG(30.0f);

        testCheatLog = new CheatMealLog();
        testCheatLog.setCheatMealLogId(1L);
        testCheatLog.setUser(testUser);
        testCheatLog.setNutritionLog(testLog);
        testCheatLog.setCheatDate(LocalDate.now());
        testCheatLog.setExcessCalories(500);
        testCheatLog.setIsCompensated(false);
    }

    @Nested
    @DisplayName("Create Nutrition Plan Tests (UC-7.1)")
    class CreateNutritionPlanTests {

        @Test
        @DisplayName("Should successfully create a nutrition plan")
        void createNutritionPlan_Success() {
            // Arrange
            CreateNutritionPlanRequest request = CreateNutritionPlanRequest.builder()
                    .planName("My Diet Plan")
                    .dailyCalorieTarget(2000)
                    .proteinPercentage(30.0f)
                    .carbsPercentage(40.0f)
                    .fatsPercentage(30.0f)
                    .cheatMealsPerWeek(2)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(planRepository.existsByUserUserId(1L)).thenReturn(false);
            when(planRepository.save(any(NutritionPlan.class))).thenReturn(testPlan);

            // Act
            NutritionPlanResponse response = nutritionService.createNutritionPlan(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getPlanName()).isEqualTo("Weight Loss Plan");
            assertThat(response.getDailyCalorieTarget()).isEqualTo(2000);
            verify(planRepository, times(1)).save(any(NutritionPlan.class));
        }

        @Test
        @DisplayName("Should calculate macro grams correctly")
        void createNutritionPlan_CalculatesMacroGrams() {
            // Arrange
            CreateNutritionPlanRequest request = CreateNutritionPlanRequest.builder()
                    .planName("My Diet Plan")
                    .dailyCalorieTarget(2000)
                    .proteinPercentage(30.0f)  // 2000 * 0.30 / 4 = 150g
                    .carbsPercentage(40.0f)    // 2000 * 0.40 / 4 = 200g
                    .fatsPercentage(30.0f)     // 2000 * 0.30 / 9 = 66.67g
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(planRepository.existsByUserUserId(1L)).thenReturn(false);
            when(planRepository.save(any(NutritionPlan.class))).thenReturn(testPlan);

            // Act
            NutritionPlanResponse response = nutritionService.createNutritionPlan(1L, request);

            // Assert
            assertThat(response.getProteinGrams()).isEqualTo(150.0f);
            assertThat(response.getCarbsGrams()).isEqualTo(200.0f);
            assertThat(response.getFatsGrams()).isCloseTo(66.67f, within(0.1f));
        }

        @Test
        @DisplayName("Should throw exception if user already has a plan")
        void createNutritionPlan_AlreadyExists() {
            // Arrange
            CreateNutritionPlanRequest request = CreateNutritionPlanRequest.builder()
                    .planName("My Diet Plan")
                    .dailyCalorieTarget(2000)
                    .proteinPercentage(30.0f)
                    .carbsPercentage(40.0f)
                    .fatsPercentage(30.0f)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(planRepository.existsByUserUserId(1L)).thenReturn(true);

            // Act & Assert
            assertThatThrownBy(() -> nutritionService.createNutritionPlan(1L, request))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("already has a nutrition plan");
        }
    }

    @Nested
    @DisplayName("Log Meal Tests (UC-7.2)")
    class LogMealTests {

        @Test
        @DisplayName("Should successfully log a meal")
        void logMeal_Success() {
            // Arrange
            LogMealRequest request = LogMealRequest.builder()
                    .mealType(MealType.LUNCH)
                    .foodName("Grilled Chicken")
                    .calories(400)
                    .proteinG(35.0f)
                    .carbsG(10.0f)
                    .fatsG(12.0f)
                    .logDate(LocalDate.now())
                    .isCheatMeal(false)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(logRepository.save(any(NutritionLog.class))).thenReturn(testLog);

            // Act
            NutritionLogResponse response = nutritionService.logMeal(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getFoodName()).isEqualTo("Chicken Salad");
            verify(logRepository, times(1)).save(any(NutritionLog.class));
        }

        @Test
        @DisplayName("Should create cheat meal log when flagged")
        void logMeal_CheatMeal_CreatesCheatLog() {
            // Arrange
            LogMealRequest request = LogMealRequest.builder()
                    .mealType(MealType.DINNER)
                    .foodName("Pizza")
                    .calories(1200)
                    .isCheatMeal(true)
                    .logDate(LocalDate.now())
                    .build();

            NutritionLog cheatMealLog = new NutritionLog();
            cheatMealLog.setNutritionId(2L);
            cheatMealLog.setUser(testUser);
            cheatMealLog.setIsCheatMeal(true);
            cheatMealLog.setCalories(1200);
            cheatMealLog.setLogDate(LocalDate.now());

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(logRepository.save(any(NutritionLog.class))).thenReturn(cheatMealLog);
            when(planRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(testPlan));

            // Act
            nutritionService.logMeal(1L, request);

            // Assert
            verify(cheatMealLogRepository, times(1)).save(any(CheatMealLog.class));
        }
    }

    @Nested
    @DisplayName("Log Meal From Template Tests (UC-7.7)")
    class LogMealFromTemplateTests {

        @Test
        @DisplayName("Should log meal from template with multiplier")
        void logMealFromTemplate_Success() {
            // Arrange
            LogMealFromTemplateRequest request = LogMealFromTemplateRequest.builder()
                    .templateId(1L)
                    .quantityMultiplier(2.0f)
                    .logDate(LocalDate.now())
                    .build();

            when(templateRepository.findByMealTemplateIdAndNutritionPlanUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testTemplate));
            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(logRepository.save(any(NutritionLog.class))).thenReturn(testLog);

            // Act
            NutritionLogResponse response = nutritionService.logMealFromTemplate(1L, request);

            // Assert
            assertThat(response).isNotNull();
            verify(logRepository, times(1)).save(any(NutritionLog.class));
        }

        @Test
        @DisplayName("Should throw exception when template not found")
        void logMealFromTemplate_TemplateNotFound() {
            // Arrange
            LogMealFromTemplateRequest request = LogMealFromTemplateRequest.builder()
                    .templateId(999L)
                    .build();

            when(templateRepository.findByMealTemplateIdAndNutritionPlanUserUserId(999L, 1L))
                    .thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> nutritionService.logMealFromTemplate(1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Meal template not found");
        }
    }

    @Nested
    @DisplayName("Daily Summary Tests (UC-7.5)")
    class DailySummaryTests {

        @Test
        @DisplayName("Should return daily nutrition summary")
        void getDailySummary_Success() {
            // Arrange
            DailyNutritionAggregate summary = new DailyNutritionAggregate() {
                @Override
                public Number getTotalCalories() {
                    return 1500;
                }

                @Override
                public Number getTotalProtein() {
                    return 120.0f;
                }

                @Override
                public Number getTotalCarbs() {
                    return 150.0f;
                }

                @Override
                public Number getTotalFats() {
                    return 50.0f;
                }
            };
            when(logRepository.getDailySummary(eq(1L), any(LocalDate.class))).thenReturn(summary);
            when(planRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(testPlan));
            when(logRepository.countByUserUserIdAndLogDateAndIsCheatMealTrue(eq(1L), any(LocalDate.class)))
                    .thenReturn(0L);

            // Act
            DailyNutritionSummaryResponse response = nutritionService.getDailySummary(1L, LocalDate.now());

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getTotalCalories()).isEqualTo(1500);
            assertThat(response.getTotalProteinG()).isEqualTo(120.0f);
            assertThat(response.getTargetCalories()).isEqualTo(2000);
            assertThat(response.getRemainingCalories()).isEqualTo(500);
        }

        @Test
        @DisplayName("Should handle no logs by returning zeros")
        void getDailySummary_NoLogs_ReturnsZeros() {
            // Arrange
            when(logRepository.getDailySummary(eq(1L), any(LocalDate.class))).thenReturn(null);
            when(planRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(testPlan));
            when(logRepository.countByUserUserIdAndLogDateAndIsCheatMealTrue(eq(1L), any(LocalDate.class)))
                    .thenReturn(0L);

            // Act
            DailyNutritionSummaryResponse response = nutritionService.getDailySummary(1L, LocalDate.now());

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getTotalCalories()).isZero();
            assertThat(response.getTotalProteinG()).isZero();
        }
    }

    @Nested
    @DisplayName("Compensation Options Tests (UC-7.4)")
    class CompensationOptionsTests {

        @Test
        @DisplayName("Should generate four compensation options")
        void generateCompensationOptions_ReturnsAllOptions() {
            // Arrange
            when(cheatMealLogRepository.findById(1L)).thenReturn(Optional.of(testCheatLog));

            // Act
            List<CompensationActionResponse> options = nutritionService.generateCompensationOptions(1L, 1L);

            // Assert
            assertThat(options).hasSize(4);
            assertThat(options.stream().map(CompensationActionResponse::getCompensationType))
                    .containsExactly(
                            CompensationType.ADD_CARDIO,
                            CompensationType.REDUCE_CALORIES,
                            CompensationType.COMBINATION,
                            CompensationType.DO_NOTHING
                    );
        }

        @Test
        @DisplayName("Should throw exception when cheat meal not found")
        void generateCompensationOptions_CheatMealNotFound() {
            // Arrange
            when(cheatMealLogRepository.findById(999L)).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> nutritionService.generateCompensationOptions(1L, 999L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Cheat meal log not found");
        }
    }

    @Nested
    @DisplayName("Select Compensation Tests (UC-7.4)")
    class SelectCompensationTests {

        @Test
        @DisplayName("Should create compensation action when selected")
        void selectCompensation_Success() {
            // Arrange
            SelectCompensationRequest request = SelectCompensationRequest.builder()
                    .compensationType(CompensationType.ADD_CARDIO)
                    .build();

            CompensationAction savedAction = new CompensationAction();
            savedAction.setCompensationId(1L);
            savedAction.setCheatMealLog(testCheatLog);
            savedAction.setActionType("ADD_CARDIO");
            savedAction.setIsCompleted(false);

            when(cheatMealLogRepository.findById(1L)).thenReturn(Optional.of(testCheatLog));
            when(compensationRepository.save(any(CompensationAction.class))).thenReturn(savedAction);

            // Act
            CompensationActionResponse response = nutritionService.selectCompensation(1L, 1L, request);

            // Assert
            assertThat(response).isNotNull();
            verify(compensationRepository, times(1)).save(any(CompensationAction.class));
            verify(cheatMealLogRepository, times(1)).save(testCheatLog);
        }

        @Test
        @DisplayName("Should mark as compensated when DO_NOTHING selected")
        void selectCompensation_DoNothing_MarksAsCompensated() {
            // Arrange
            SelectCompensationRequest request = SelectCompensationRequest.builder()
                    .compensationType(CompensationType.DO_NOTHING)
                    .build();

            when(cheatMealLogRepository.findById(1L)).thenReturn(Optional.of(testCheatLog));

            // Act
            nutritionService.selectCompensation(1L, 1L, request);

            // Assert
            assertThat(testCheatLog.getIsCompensated()).isTrue();
            verify(compensationRepository, never()).save(any(CompensationAction.class));
        }
    }

    @Nested
    @DisplayName("Meal Template Tests (UC-7.6)")
    class MealTemplateTests {

        @Test
        @DisplayName("Should create meal template successfully")
        void createMealTemplate_Success() {
            // Arrange
            CreateMealTemplateRequest request = CreateMealTemplateRequest.builder()
                    .mealName("Post-Workout Shake")
                    .mealType(MealType.SNACK)
                    .calories(300)
                    .proteinG(40.0f)
                    .build();

            when(planRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(testPlan));
            when(templateRepository.save(any(MealTemplate.class))).thenReturn(testTemplate);

            // Act
            MealTemplateResponse response = nutritionService.createMealTemplate(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getMealName()).isEqualTo("Protein Shake");
            verify(templateRepository, times(1)).save(any(MealTemplate.class));
        }

        @Test
        @DisplayName("Should throw exception when no nutrition plan exists")
        void createMealTemplate_NoPlan() {
            // Arrange
            CreateMealTemplateRequest request = CreateMealTemplateRequest.builder()
                    .mealName("Test Meal")
                    .mealType(MealType.SNACK)
                    .calories(200)
                    .build();

            when(planRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> nutritionService.createMealTemplate(1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("No active nutrition plan");
        }

        @Test
        @DisplayName("Should delete meal template")
        void deleteMealTemplate_Success() {
            // Arrange
            when(templateRepository.findByMealTemplateIdAndNutritionPlanUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testTemplate));

            // Act
            nutritionService.deleteMealTemplate(1L, 1L);

            // Assert
            verify(templateRepository, times(1)).delete(testTemplate);
        }
    }

    private static org.assertj.core.data.Offset<Float> within(float value) {
        return org.assertj.core.data.Offset.offset(value);
    }
}
