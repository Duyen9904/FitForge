package com.dev.backend.service.impl;

import com.dev.backend.model.dto.response.AdminAnalyticsResponse;
import com.dev.backend.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests for AdminAnalyticsServiceImpl (UC-16.3)
 */
@ExtendWith(MockitoExtension.class)
class AdminAnalyticsServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private WorkoutProgressRepository workoutProgressRepository;

    @Mock
    private ExerciseRepository exerciseRepository;

    @Mock
    private GoalRepository goalRepository;

    @Mock
    private MissedWorkoutRepository missedWorkoutRepository;

    @Mock
    private CheatMealLogRepository cheatMealLogRepository;

    @Mock
    private UserMeasurementRepository userMeasurementRepository;

    @Mock
    private ProgressPhotoRepository progressPhotoRepository;

    private AdminAnalyticsServiceImpl adminAnalyticsService;

    @BeforeEach
    void setUp() {
        adminAnalyticsService = new AdminAnalyticsServiceImpl(
                userRepository,
                workoutProgressRepository,
                exerciseRepository,
                goalRepository,
                missedWorkoutRepository,
                cheatMealLogRepository,
                userMeasurementRepository,
                progressPhotoRepository
        );
    }

    @Nested
    @DisplayName("getSystemAnalytics (UC-16.3)")
    class GetSystemAnalyticsTests {

        @Test
        @DisplayName("Should return comprehensive system analytics")
        void getSystemAnalytics_Success() {
            // Given
            when(userRepository.count()).thenReturn(1000L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(750L);
            when(workoutProgressRepository.count()).thenReturn(50000L);
            when(missedWorkoutRepository.count()).thenReturn(5000L);
            when(cheatMealLogRepository.count()).thenReturn(2000L);
            when(userMeasurementRepository.count()).thenReturn(10000L);
            when(progressPhotoRepository.count()).thenReturn(3000L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            AdminAnalyticsResponse result = adminAnalyticsService.getSystemAnalytics();

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTotalUsers()).isEqualTo(1000L);
            assertThat(result.getActiveUsersLast30Days()).isEqualTo(750L);
            assertThat(result.getTotalWorkoutsCompleted()).isEqualTo(50000L);
            assertThat(result.getAverageWorkoutsPerUser()).isEqualTo(50.0); // 50000/1000
            assertThat(result.getTotalCheatMealsLogged()).isEqualTo(2000L);
            assertThat(result.getTotalMissedWorkouts()).isEqualTo(5000L);
            assertThat(result.getTotalMeasurementsRecorded()).isEqualTo(10000L);
            assertThat(result.getTotalProgressPhotos()).isEqualTo(3000L);
        }

        @Test
        @DisplayName("Should calculate adherence rate correctly")
        void getSystemAnalytics_AdherenceRate() {
            // Given - 80% adherence (8000 completed, 2000 missed = 10000 total)
            when(userRepository.count()).thenReturn(100L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(80L);
            when(workoutProgressRepository.count()).thenReturn(8000L);
            when(missedWorkoutRepository.count()).thenReturn(2000L);
            when(cheatMealLogRepository.count()).thenReturn(0L);
            when(userMeasurementRepository.count()).thenReturn(0L);
            when(progressPhotoRepository.count()).thenReturn(0L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            AdminAnalyticsResponse result = adminAnalyticsService.getSystemAnalytics();

            // Then
            assertThat(result.getAverageAdherenceRatePercent()).isEqualTo(80.0);
        }

        @Test
        @DisplayName("Should handle zero users gracefully")
        void getSystemAnalytics_NoUsers() {
            // Given
            when(userRepository.count()).thenReturn(0L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(0L);
            when(workoutProgressRepository.count()).thenReturn(0L);
            when(missedWorkoutRepository.count()).thenReturn(0L);
            when(cheatMealLogRepository.count()).thenReturn(0L);
            when(userMeasurementRepository.count()).thenReturn(0L);
            when(progressPhotoRepository.count()).thenReturn(0L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            AdminAnalyticsResponse result = adminAnalyticsService.getSystemAnalytics();

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTotalUsers()).isEqualTo(0L);
            assertThat(result.getAverageWorkoutsPerUser()).isEqualTo(0.0);
            assertThat(result.getAverageAdherenceRatePercent()).isEqualTo(0.0);
        }

        @Test
        @DisplayName("Should include popular exercises and goals")
        void getSystemAnalytics_PopularItems() {
            // Given
            when(userRepository.count()).thenReturn(100L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(50L);
            when(workoutProgressRepository.count()).thenReturn(1000L);
            when(missedWorkoutRepository.count()).thenReturn(100L);
            when(cheatMealLogRepository.count()).thenReturn(50L);
            when(userMeasurementRepository.count()).thenReturn(200L);
            when(progressPhotoRepository.count()).thenReturn(30L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            AdminAnalyticsResponse result = adminAnalyticsService.getSystemAnalytics();

            // Then
            assertThat(result.getMostPopularExercises()).isNotNull();
            assertThat(result.getMostPopularGoals()).isNotNull();
            assertThat(result.getMissedWorkoutReasons()).isNotNull();
        }
    }

    @Nested
    @DisplayName("exportAnalyticsReport (UC-16.3)")
    class ExportAnalyticsReportTests {

        @Test
        @DisplayName("Should export analytics as CSV")
        void exportAnalyticsReport_Success() {
            // Given
            when(userRepository.count()).thenReturn(100L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(50L);
            when(workoutProgressRepository.count()).thenReturn(1000L);
            when(missedWorkoutRepository.count()).thenReturn(100L);
            when(cheatMealLogRepository.count()).thenReturn(50L);
            when(userMeasurementRepository.count()).thenReturn(200L);
            when(progressPhotoRepository.count()).thenReturn(30L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            byte[] result = adminAnalyticsService.exportAnalyticsReport();

            // Then
            assertThat(result).isNotNull();
            assertThat(result.length).isGreaterThan(0);

            String csv = new String(result);
            assertThat(csv).contains("Metric,Value");
            assertThat(csv).contains("Total Users,100");
            assertThat(csv).contains("Active Users (Last 30 Days),50");
            assertThat(csv).contains("Total Workouts Completed,1000");
        }

        @Test
        @DisplayName("Should include all sections in CSV export")
        void exportAnalyticsReport_AllSections() {
            // Given
            when(userRepository.count()).thenReturn(10L);
            when(userRepository.countActiveUsersSince(any(LocalDate.class))).thenReturn(5L);
            when(workoutProgressRepository.count()).thenReturn(100L);
            when(missedWorkoutRepository.count()).thenReturn(10L);
            when(cheatMealLogRepository.count()).thenReturn(5L);
            when(userMeasurementRepository.count()).thenReturn(20L);
            when(progressPhotoRepository.count()).thenReturn(3L);
            when(exerciseRepository.findAll()).thenReturn(java.util.List.of());
            when(goalRepository.findAll()).thenReturn(java.util.List.of());

            // When
            byte[] result = adminAnalyticsService.exportAnalyticsReport();
            String csv = new String(result);

            // Then
            assertThat(csv).contains("Most Popular Exercises");
            assertThat(csv).contains("Most Popular Goals");
            assertThat(csv).contains("Missed Workout Reasons");
        }
    }
}
