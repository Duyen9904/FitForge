package com.dev.backend.service.impl;

import com.dev.backend.model.dto.request.DataExportRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.projection.DailyNutritionTrendAggregate;
import com.dev.backend.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReportServiceImplTest {

    @Mock
    private WorkoutProgressRepository workoutProgressRepository;

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private NutritionPlanRepository nutritionPlanRepository;

    @Mock
    private UserMeasurementRepository userMeasurementRepository;

    @Mock
    private ProgressPhotoRepository progressPhotoRepository;

    @Mock
    private UserAchievementRepository userAchievementRepository;

    @Mock
    private MissedWorkoutRepository missedWorkoutRepository;

    @Mock
    private ExerciseLogRepository exerciseLogRepository;

    @InjectMocks
    private ReportServiceImpl reportService;

    private LocalDate startDate;
    private LocalDate endDate;

    @BeforeEach
    void setUp() {
        startDate = LocalDate.of(2026, 1, 1);
        endDate = LocalDate.of(2026, 1, 31);
    }

    static class TestDailyNutritionTrendAggregate implements DailyNutritionTrendAggregate {
        private final LocalDate logDate;
        private final Number totalCalories;
        private final Number totalProtein;
        private final Number totalCarbs;
        private final Number totalFats;

        public TestDailyNutritionTrendAggregate(LocalDate logDate, Number totalCalories,
                                                Number totalProtein, Number totalCarbs, Number totalFats) {
            this.logDate = logDate;
            this.totalCalories = totalCalories;
            this.totalProtein = totalProtein;
            this.totalCarbs = totalCarbs;
            this.totalFats = totalFats;
        }

        @Override
        public LocalDate getLogDate() {
            return logDate;
        }

        @Override
        public Number getTotalCalories() {
            return totalCalories;
        }

        @Override
        public Number getTotalProtein() {
            return totalProtein;
        }

        @Override
        public Number getTotalCarbs() {
            return totalCarbs;
        }

        @Override
        public Number getTotalFats() {
            return totalFats;
        }
    }

    @Nested
    @DisplayName("generateWorkoutSummaryReport")
    class GenerateWorkoutSummaryReportTests {

        @Test
        @DisplayName("Should generate workout summary report with completed workouts")
        void generateWorkoutSummaryReport_Success() {
            // Given
            WorkoutProgress wp1 = new WorkoutProgress();
            wp1.setCompleted(true);
            wp1.setDurationMinutes(60);
            wp1.setCaloriesBurned(400);

            WorkoutProgress wp2 = new WorkoutProgress();
            wp2.setCompleted(true);
            wp2.setDurationMinutes(45);
            wp2.setCaloriesBurned(300);

            when(workoutProgressRepository.findByUserIdAndDateRange(anyLong(), any(Instant.class), any(Instant.class)))
                    .thenReturn(Arrays.asList(wp1, wp2));
            when(missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(2L);

            // When
            WorkoutSummaryReportResponse result = reportService.generateWorkoutSummaryReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTotalWorkoutsCompleted()).isEqualTo(2);
            assertThat(result.getTotalWorkoutsPlanned()).isEqualTo(4);
            assertThat(result.getTotalDurationMinutes()).isEqualTo(105);
            assertThat(result.getTotalCaloriesBurned()).isEqualTo(700);
            assertThat(result.getMissedWorkouts()).isEqualTo(2);
            assertThat(result.getAdherencePercentage()).isEqualTo(50.0);
        }

        @Test
        @DisplayName("Should handle empty workout history")
        void generateWorkoutSummaryReport_EmptyHistory() {
            // Given
            when(workoutProgressRepository.findByUserIdAndDateRange(anyLong(), any(Instant.class), any(Instant.class)))
                    .thenReturn(List.of());
            when(missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(0L);

            // When
            WorkoutSummaryReportResponse result = reportService.generateWorkoutSummaryReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTotalWorkoutsCompleted()).isEqualTo(0);
            assertThat(result.getAdherencePercentage()).isEqualTo(100.0); // 100% when no planned
        }
    }

    @Nested
    @DisplayName("generateNutritionReport")
    class GenerateNutritionReportTests {

        @Test
        @DisplayName("Should generate nutrition report with daily totals")
        void generateNutritionReport_Success() {
            // Given
            List<DailyNutritionTrendAggregate> dailyTotals = Arrays.asList(
                    new TestDailyNutritionTrendAggregate(LocalDate.of(2026, 1, 1), 2200, 150.0, 250.0, 70.0),
                    new TestDailyNutritionTrendAggregate(LocalDate.of(2026, 1, 2), 2100, 140.0, 240.0, 65.0)
            );

            when(nutritionLogRepository.getDailyTotals(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(dailyTotals);
            when(nutritionLogRepository.countCheatDaysBetween(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(1L);

            // When
            NutritionReportResponse result = reportService.generateNutritionReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getAverageDailyCalories()).isEqualTo(2150.0);
            assertThat(result.getAverageDailyProtein()).isEqualTo(145.0);
            assertThat(result.getDailyBreakdown()).hasSize(2);
            assertThat(result.getTotalCheatMealDays()).isEqualTo(1);
        }

        @Test
        @DisplayName("Should return empty report when no nutrition data")
        void generateNutritionReport_NoData() {
            // Given
            when(nutritionLogRepository.getDailyTotals(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(List.of());

            // When
            NutritionReportResponse result = reportService.generateNutritionReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getAverageDailyCalories()).isNull();
            assertThat(result.getRecommendations()).contains("Start logging your meals to get nutrition insights");
        }
    }

    @Nested
    @DisplayName("generateTransformationReport")
    class GenerateTransformationReportTests {

        @Test
        @DisplayName("Should generate transformation report with weight changes")
        void generateTransformationReport_Success() {
            // Given
            User user = new User();
            user.setUserId(1L);

            UserMeasurement m1 = new UserMeasurement();
            m1.setMeasurementDate(LocalDate.of(2026, 1, 1));
            m1.setWeightKg(80.0f);
            m1.setUser(user);

            UserMeasurement m2 = new UserMeasurement();
            m2.setMeasurementDate(LocalDate.of(2026, 1, 31));
            m2.setWeightKg(78.5f);
            m2.setUser(user);

            when(userMeasurementRepository.findByUserUserIdAndMeasurementDateBetween(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(Arrays.asList(m1, m2));
            when(userAchievementRepository.findByUserUserIdOrderByEarnedDateDesc(anyLong()))
                    .thenReturn(List.of());

            // When
            TransformationReportResponse result = reportService.generateTransformationReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getStartingWeight()).isEqualTo(80.0f);
            assertThat(result.getCurrentWeight()).isEqualTo(78.5f);
            assertThat(result.getWeightChange()).isEqualTo(-1.5f);
            assertThat(result.getWeightHistory()).hasSize(2);
            assertThat(result.getMilestones()).contains("Lost 1.5 kg - Great progress!");
        }

        @Test
        @DisplayName("Should handle no measurements")
        void generateTransformationReport_NoMeasurements() {
            // Given
            when(userMeasurementRepository.findByUserUserIdAndMeasurementDateBetween(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(List.of());

            // When
            TransformationReportResponse result = reportService.generateTransformationReport(1L, startDate, endDate);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getStartingWeight()).isNull();
            assertThat(result.getMilestones()).contains("Start tracking your measurements to see your transformation");
        }
    }

    @Nested
    @DisplayName("exportData")
    class ExportDataTests {

        @Test
        @DisplayName("Should export data as JSON bytes")
        void exportData_Success() {
            // Given
            DataExportRequest request = DataExportRequest.builder()
                    .dataTypes(Arrays.asList(
                            DataExportRequest.ExportDataType.WORKOUT_HISTORY,
                            DataExportRequest.ExportDataType.NUTRITION_LOGS))
                    .format(DataExportRequest.ExportFormat.JSON)
                    .startDate(startDate)
                    .endDate(endDate)
                    .build();

            // When
            byte[] result = reportService.exportData(1L, request);

            // Then
            assertThat(result).isNotNull();
            String json = new String(result);
            assertThat(json).contains("userId");
            assertThat(json).contains("workoutHistory");
            assertThat(json).contains("nutritionLogs");
        }
    }
}
