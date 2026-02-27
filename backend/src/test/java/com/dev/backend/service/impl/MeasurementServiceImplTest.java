package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.MeasurementMapper;
import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.response.MeasurementGoalResponse;
import com.dev.backend.model.dto.response.MeasurementHistoryResponse;
import com.dev.backend.model.dto.response.MeasurementResponse;
import com.dev.backend.model.entity.MeasurementGoal;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserMeasurement;
import com.dev.backend.repository.MeasurementGoalRepository;
import com.dev.backend.repository.ProgressPhotoRepository;
import com.dev.backend.repository.UserMeasurementRepository;
import com.dev.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MeasurementServiceImplTest {

    @Mock
    private UserMeasurementRepository measurementRepository;

    @Mock
    private MeasurementGoalRepository goalRepository;

    @Mock
    private ProgressPhotoRepository photoRepository;

    @Mock
    private UserRepository userRepository;

    @Spy
    private MeasurementMapper mapper = new MeasurementMapper();

    @InjectMocks
    private MeasurementServiceImpl measurementService;

    private User testUser;
    private UserMeasurement testMeasurement;
    private MeasurementGoal testGoal;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");

        testMeasurement = new UserMeasurement();
        testMeasurement.setMeasurementId(1L);
        testMeasurement.setUser(testUser);
        testMeasurement.setMeasurementDate(LocalDate.now());
        testMeasurement.setWeightKg(75.0f);
        testMeasurement.setBodyFatPercentage(18.0f);
        testMeasurement.setWaistCm(85.0f);

        testGoal = new MeasurementGoal();
        testGoal.setGoalId(1L);
        testGoal.setUser(testUser);
        testGoal.setTargetWeightKg(70.0f);
        testGoal.setTargetBodyFatPercentage(15.0f);
        testGoal.setTargetDate(LocalDate.now().plusMonths(3));
        testGoal.setIsActive(true);
    }

    @Nested
    @DisplayName("Record Measurement Tests (UC-8.1)")
    class RecordMeasurementTests {

        @Test
        @DisplayName("Should successfully record a new measurement")
        void recordMeasurement_Success() {
            // Arrange
            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(75.0f)
                    .bodyFatPercentage(18.0f)
                    .waistCm(85.0f)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.empty());
            when(measurementRepository.findByUserUserIdAndMeasurementDate(1L, request.getMeasurementDate()))
                    .thenReturn(Optional.empty());
            when(measurementRepository.save(any(UserMeasurement.class))).thenReturn(testMeasurement);

            // Act
            MeasurementResponse response = measurementService.recordMeasurement(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getWeightKg()).isEqualTo(75.0f);
            assertThat(response.getBodyFatPercentage()).isEqualTo(18.0f);
            verify(measurementRepository, times(1)).save(any(UserMeasurement.class));
        }

        @Test
        @DisplayName("Should calculate weight change from previous measurement")
        void recordMeasurement_CalculatesChange() {
            // Arrange
            UserMeasurement previousMeasurement = new UserMeasurement();
            previousMeasurement.setWeightKg(78.0f);
            previousMeasurement.setBodyFatPercentage(20.0f);

            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(75.0f)
                    .bodyFatPercentage(18.0f)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.of(previousMeasurement));
            when(measurementRepository.findByUserUserIdAndMeasurementDate(1L, request.getMeasurementDate()))
                    .thenReturn(Optional.empty());
            when(measurementRepository.save(any(UserMeasurement.class))).thenReturn(testMeasurement);

            // Act
            MeasurementResponse response = measurementService.recordMeasurement(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getWeightChange()).isEqualTo(-3.0f); // 75 - 78 = -3
            assertThat(response.getBodyFatChange()).isEqualTo(-2.0f); // 18 - 20 = -2
        }

        @Test
        @DisplayName("Should throw exception when user not found")
        void recordMeasurement_UserNotFound() {
            // Arrange
            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(75.0f)
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> measurementService.recordMeasurement(1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("User not found");
        }
    }

    @Nested
    @DisplayName("Get Latest Measurement Tests")
    class GetLatestMeasurementTests {

        @Test
        @DisplayName("Should return latest measurement")
        void getLatestMeasurement_Success() {
            // Arrange
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.of(testMeasurement));
            when(measurementRepository.findByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(List.of(testMeasurement));

            // Act
            MeasurementResponse response = measurementService.getLatestMeasurement(1L);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getMeasurementId()).isEqualTo(1L);
            assertThat(response.getWeightKg()).isEqualTo(75.0f);
        }

        @Test
        @DisplayName("Should throw exception when no measurements found")
        void getLatestMeasurement_NotFound() {
            // Arrange
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> measurementService.getLatestMeasurement(1L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("No measurements found");
        }
    }

    @Nested
    @DisplayName("Measurement History Tests (UC-8.2)")
    class MeasurementHistoryTests {

        @Test
        @DisplayName("Should return measurement history with trends")
        void getMeasurementHistory_Success() {
            // Arrange
            UserMeasurement oldMeasurement = new UserMeasurement();
            oldMeasurement.setMeasurementId(2L);
            oldMeasurement.setUser(testUser);
            oldMeasurement.setMeasurementDate(LocalDate.now().minusDays(7));
            oldMeasurement.setWeightKg(77.0f);

            when(measurementRepository.findByUserUserIdAndMeasurementDateBetween(
                    eq(1L), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(List.of(testMeasurement, oldMeasurement));
            when(goalRepository.findByUserUserIdAndIsActiveTrue(1L))
                    .thenReturn(Optional.of(testGoal));

            // Act
            MeasurementHistoryResponse response = measurementService.getMeasurementHistory(
                    1L, LocalDate.now().minusDays(30), LocalDate.now());

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getMeasurements()).hasSize(2);
            assertThat(response.getTrends()).isNotNull();
            assertThat(response.getProgressIndicators()).isNotNull();
        }

        @Test
        @DisplayName("Should return empty history when no measurements")
        void getMeasurementHistory_Empty() {
            // Arrange
            when(measurementRepository.findByUserUserIdAndMeasurementDateBetween(
                    eq(1L), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(List.of());

            // Act
            MeasurementHistoryResponse response = measurementService.getMeasurementHistory(
                    1L, LocalDate.now().minusDays(30), LocalDate.now());

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getMeasurements()).isEmpty();
        }
    }

    @Nested
    @DisplayName("Set Measurement Goal Tests (UC-8.3)")
    class SetMeasurementGoalTests {

        @Test
        @DisplayName("Should successfully set a new goal")
        void setMeasurementGoal_Success() {
            // Arrange
            SetMeasurementGoalRequest request = SetMeasurementGoalRequest.builder()
                    .targetWeightKg(70.0f)
                    .targetBodyFatPercentage(15.0f)
                    .targetDate(LocalDate.now().plusMonths(3))
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(goalRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.empty());
            when(goalRepository.save(any(MeasurementGoal.class))).thenReturn(testGoal);
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.of(testMeasurement));

            // Act
            MeasurementGoalResponse response = measurementService.setMeasurementGoal(1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getTargetWeightKg()).isEqualTo(70.0f);
            verify(goalRepository, times(1)).save(any(MeasurementGoal.class));
        }

        @Test
        @DisplayName("Should deactivate existing goal when setting new one")
        void setMeasurementGoal_DeactivatesExisting() {
            // Arrange
            MeasurementGoal existingGoal = new MeasurementGoal();
            existingGoal.setGoalId(2L);
            existingGoal.setIsActive(true);

            SetMeasurementGoalRequest request = SetMeasurementGoalRequest.builder()
                    .targetWeightKg(70.0f)
                    .targetDate(LocalDate.now().plusMonths(3))
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
            when(goalRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(existingGoal));
            when(goalRepository.save(any(MeasurementGoal.class))).thenReturn(testGoal);
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.empty());

            // Act
            measurementService.setMeasurementGoal(1L, request);

            // Assert
            assertThat(existingGoal.getIsActive()).isFalse();
        }
    }

    @Nested
    @DisplayName("Get Measurement Goal Tests")
    class GetMeasurementGoalTests {

        @Test
        @DisplayName("Should return active goal")
        void getMeasurementGoal_Success() {
            // Arrange
            when(goalRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.of(testGoal));
            when(measurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(1L))
                    .thenReturn(Optional.of(testMeasurement));

            // Act
            MeasurementGoalResponse response = measurementService.getMeasurementGoal(1L);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getTargetWeightKg()).isEqualTo(70.0f);
            assertThat(response.getDaysRemaining()).isNotNull();
        }

        @Test
        @DisplayName("Should throw exception when no active goal")
        void getMeasurementGoal_NotFound() {
            // Arrange
            when(goalRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> measurementService.getMeasurementGoal(1L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("No active measurement goal");
        }
    }
}
