package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.model.entity.User;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.NutritionLogRepository;
import com.dev.backend.repository.NutritionPlanRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.UserProfileService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NutritionRecommendationServiceImplTest {

    private static final long USER_ID = 123L;
    private static final long PLAN_ID = 20L;

    @Mock
    private UserProfileService userProfileService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private NutritionPlanRepository nutritionPlanRepository;

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private GoalRepository goalRepository;

    @InjectMocks
    private NutritionRecommendationServiceImpl nutritionRecommendationService;

    private User user;

    @BeforeEach
    void setUp() {
        Goal goal = new Goal();
        goal.setGoalId(1L);
        goal.setGoalName("Build Muscle");

        user = new User();
        user.setUserId(USER_ID);
        user.setPrimaryGoal(goal);
    }

    private UserProfile baseProfile(String primaryGoalName) {
        return UserProfile.builder()
                .userId(USER_ID)
                .gender("MALE")
                .ageYears(30)
                .heightCm(180f)
                .currentWeightKg(80f)
                .scheduleDays(java.util.List.of("MON", "WED", "FRI"))
                .primaryGoalName(primaryGoalName)
                .build();
    }

    private NutritionPlan currentPlan() {
        NutritionPlan plan = new NutritionPlan();
        plan.setNutritionPlanId(PLAN_ID);
        plan.setUser(user);
        plan.setPlanName("Personalized Nutrition Plan");
        plan.setDailyCalorieTarget(2200);
        plan.setProteinPercentage(30f);
        plan.setCarbsPercentage(40f);
        plan.setFatsPercentage(30f);
        plan.setCheatMealsPerWeek(2);
        plan.setAlgorithmVersion("RULE_BASED_V1");
        plan.setVersion(1);
        plan.setRecommendationReason("Reason");
        plan.setAutoAdjustEnabled(true);
        plan.setIsActive(true);
        return plan;
    }

    @Nested
    @DisplayName("generateInitialPlan")
    class GenerateInitialPlanTests {

        @Test
        @DisplayName("Should generate plan with muscle gain adjustments")
        void generateInitialPlan_MuscleGain() {
            UserProfile profile = baseProfile("Muscle Gain");

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(userProfileService.buildProfile(USER_ID)).thenReturn(profile);

            ArgumentCaptor<NutritionPlan> captor = ArgumentCaptor.forClass(NutritionPlan.class);

            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.generateInitialPlan(USER_ID);

            verify(nutritionPlanRepository).save(captor.capture());
            NutritionPlan toSave = captor.getValue();

            assertThat(toSave.getUser()).isEqualTo(user);
            assertThat(toSave.getPlanName()).isEqualTo("Personalized Nutrition Plan");
            assertThat(toSave.getAlgorithmVersion()).isEqualTo("RULE_BASED_V1");
            assertThat(toSave.getVersion()).isEqualTo(1);
            assertThat(toSave.getCheatMealsPerWeek()).isEqualTo(2);
            assertThat(toSave.getAutoAdjustEnabled()).isTrue();
            assertThat(toSave.getIsActive()).isTrue();

            // Macros for muscle gain
            assertThat(toSave.getProteinPercentage()).isEqualTo(35f);
            assertThat(toSave.getCarbsPercentage()).isEqualTo(40f);
            assertThat(toSave.getFatsPercentage()).isEqualTo(25f);

            assertThat(toSave.getDailyCalorieTarget()).isGreaterThan(0);
            assertThat(toSave.getRecommendationReason())
                    .contains("Maintenance calories estimated")
                    .contains("Muscle gain goal: increasing by 10%");

            assertThat(result).isSameAs(toSave);
        }

        @Test
        @DisplayName("Should generate plan with fat loss adjustments")
        void generateInitialPlan_FatLoss() {
            UserProfile profile = baseProfile("Fat Loss");

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(userProfileService.buildProfile(USER_ID)).thenReturn(profile);
            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.generateInitialPlan(USER_ID);

            assertThat(result.getProteinPercentage()).isEqualTo(35f);
            assertThat(result.getCarbsPercentage()).isEqualTo(30f);
            assertThat(result.getFatsPercentage()).isEqualTo(35f);
            assertThat(result.getDailyCalorieTarget()).isGreaterThan(0);
            assertThat(result.getRecommendationReason())
                    .contains("Maintenance calories estimated")
                    .contains("Fat loss goal: reducing by 15%");
        }

        @Test
        @DisplayName("Should use maintenance calories and default macros when no goal specified")
        void generateInitialPlan_NoGoal_UsesMaintenance() {
            UserProfile profile = baseProfile(null);

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(userProfileService.buildProfile(USER_ID)).thenReturn(profile);
            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.generateInitialPlan(USER_ID);

            assertThat(result.getProteinPercentage()).isEqualTo(30f);
            assertThat(result.getCarbsPercentage()).isEqualTo(40f);
            assertThat(result.getFatsPercentage()).isEqualTo(30f);
            assertThat(result.getDailyCalorieTarget()).isGreaterThan(0);
            assertThat(result.getRecommendationReason())
                    .contains("Maintenance calories estimated");
        }

        @Test
        @DisplayName("Should fall back to default calories when profile data missing")
        void generateInitialPlan_MissingProfileData_UsesFallback() {
            UserProfile profile = UserProfile.builder()
                    .userId(USER_ID)
                    .primaryGoalName("Muscle Gain")
                    .gender(null)
                    .ageYears(null)
                    .heightCm(null)
                    .currentWeightKg(null)
                    .build();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(userProfileService.buildProfile(USER_ID)).thenReturn(profile);
            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.generateInitialPlan(USER_ID);

            assertThat(result.getDailyCalorieTarget()).isEqualTo(2000);
            assertThat(result.getRecommendationReason())
                    .contains("Maintenance calories estimated at 2000");
        }

        @Test
        @DisplayName("Should propagate ResourceNotFoundException when user not found")
        void generateInitialPlan_UserNotFound_Throws() {
            when(userRepository.findById(USER_ID)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> nutritionRecommendationService.generateInitialPlan(USER_ID))
                    .isInstanceOf(ResourceNotFoundException.class);
        }
    }

    @Nested
    @DisplayName("adjustPlanBasedOnBehavior")
    class AdjustPlanBasedOnBehaviorTests {

        @Test
        @DisplayName("Should return current plan unchanged when no behavior notes added")
        void adjustPlanBasedOnBehavior_NoAdjustment() {
            NutritionPlan plan = currentPlan();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(nutritionPlanRepository.findById(PLAN_ID)).thenReturn(Optional.of(plan));
            when(nutritionLogRepository.countDistinctLogDatesByUserAndDateRange(
                    org.mockito.ArgumentMatchers.eq(USER_ID),
                    any(LocalDate.class),
                    any(LocalDate.class)))
                    .thenReturn(0L);

            NutritionPlan result = nutritionRecommendationService.adjustPlanBasedOnBehavior(USER_ID, PLAN_ID);

            assertThat(result).isSameAs(plan);
            verify(nutritionPlanRepository, never()).save(any(NutritionPlan.class));
        }

        @Test
        @DisplayName("Should add low adherence reminder when logging days are low")
        void adjustPlanBasedOnBehavior_LowAdherence_AddsReminder() {
            NutritionPlan plan = currentPlan();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(nutritionPlanRepository.findById(PLAN_ID)).thenReturn(Optional.of(plan));
            when(nutritionLogRepository.countDistinctLogDatesByUserAndDateRange(
                    org.mockito.ArgumentMatchers.eq(USER_ID),
                    any(LocalDate.class),
                    any(LocalDate.class)))
                    .thenReturn(2L); // adherence ~0.28

            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.adjustPlanBasedOnBehavior(USER_ID, PLAN_ID);

            assertThat(result.getRecommendationReason())
                    .contains("Low logging adherence - consider setting reminders");
        }

        @Test
        @DisplayName("Should add high adherence message when logging days are high")
        void adjustPlanBasedOnBehavior_HighAdherence_AddsNote() {
            NutritionPlan plan = currentPlan();

            when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
            when(nutritionPlanRepository.findById(PLAN_ID)).thenReturn(Optional.of(plan));
            when(nutritionLogRepository.countDistinctLogDatesByUserAndDateRange(
                    org.mockito.ArgumentMatchers.eq(USER_ID),
                    any(LocalDate.class),
                    any(LocalDate.class)))
                    .thenReturn(6L); // adherence ~0.86

            when(nutritionPlanRepository.save(any(NutritionPlan.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            NutritionPlan result = nutritionRecommendationService.adjustPlanBasedOnBehavior(USER_ID, PLAN_ID);

            assertThat(result.getRecommendationReason())
                    .contains("High adherence maintained.");
        }

        @Test
        @DisplayName("Should propagate ResourceNotFoundException when user or plan not found")
        void adjustPlanBasedOnBehavior_NotFound_Throws() {
            when(userRepository.findById(USER_ID)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> nutritionRecommendationService.adjustPlanBasedOnBehavior(USER_ID, PLAN_ID))
                    .isInstanceOf(ResourceNotFoundException.class);
        }
    }
}

