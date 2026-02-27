package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.MissedWorkoutMapper;
import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.request.SelectMakeupOptionRequest;
import com.dev.backend.model.dto.response.MakeupWorkoutOptionResponse;
import com.dev.backend.model.dto.response.MissedWorkoutReportResponse;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.MakeupOption;
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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MissedWorkoutServiceImplTest {

    @Mock
    private MissedWorkoutRepository missedWorkoutRepository;

    @Mock
    private WorkoutSessionRepository sessionRepository;

    @Mock
    private WorkoutPlanRepository planRepository;

    @Mock
    private WorkoutProgressRepository progressRepository;

    @Mock
    private CompensationActionRepository compensationRepository;

    @Mock
    private MakeupWorkoutRepository makeupRepository;

    @Mock
    private UserRepository userRepository;

    @Spy
    private MissedWorkoutMapper mapper = new MissedWorkoutMapper();

    @InjectMocks
    private MissedWorkoutServiceImpl missedWorkoutService;

    private User testUser;
    private WorkoutPlan testPlan;
    private WorkoutSession testSession;
    private MissedWorkout testMissedWorkout;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");

        testPlan = new WorkoutPlan();
        testPlan.setPlanId(1L);
        testPlan.setUser(testUser);
        testPlan.setPlanName("Strength Training");
        testPlan.setWorkoutSessions(new HashSet<>());

        testSession = new WorkoutSession();
        testSession.setSessionId(1L);
        testSession.setWorkoutPlan(testPlan);
        testSession.setSessionName("Push Day");
        testSession.setDayNumber(1);
        testSession.setIsRestDay(false);

        testMissedWorkout = new MissedWorkout();
        testMissedWorkout.setMissedWorkoutId(1L);
        testMissedWorkout.setUser(testUser);
        testMissedWorkout.setWorkoutPlan(testPlan);
        testMissedWorkout.setWorkoutSession(testSession);
        testMissedWorkout.setScheduledDate(LocalDate.now().minusDays(1));
        testMissedWorkout.setMissedDate(LocalDate.now());
        testMissedWorkout.setReason("TOO_BUSY");
        testMissedWorkout.setIsReplanned(false);
        testMissedWorkout.setCompensationActions(new ArrayList<>());
    }

    @Nested
    @DisplayName("Auto-detect Missed Workouts (cron)")
    class DetectAndLogMissedWorkoutsForDateTests {

        @Test
        @DisplayName("Should create missed workout for uncompleted scheduled session")
        void detectAndLogMissedWorkoutsForDate_CreatesMissedWorkout() {
            LocalDate targetDate = LocalDate.now().minusDays(1);

            when(sessionRepository.findScheduledSessionsByDate(targetDate))
                    .thenReturn(List.of(testSession));
            when(progressRepository.countCompletedWorkoutsForSessionOnDate(
                    eq(1L), eq(1L), any(), any()))
                    .thenReturn(0L);
            when(missedWorkoutRepository.findByUserUserIdAndWorkoutSessionSessionId(1L, 1L))
                    .thenReturn(Optional.empty());
            when(missedWorkoutRepository.save(any(MissedWorkout.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            missedWorkoutService.detectAndLogMissedWorkoutsForDate(targetDate);

            verify(missedWorkoutRepository, times(1)).save(any(MissedWorkout.class));
        }

        @Test
        @DisplayName("Should not create missed workout when session is completed")
        void detectAndLogMissedWorkoutsForDate_SkipsCompleted() {
            LocalDate targetDate = LocalDate.now().minusDays(1);

            when(sessionRepository.findScheduledSessionsByDate(targetDate))
                    .thenReturn(List.of(testSession));
            when(progressRepository.countCompletedWorkoutsForSessionOnDate(
                    eq(1L), eq(1L), any(), any()))
                    .thenReturn(1L);

            missedWorkoutService.detectAndLogMissedWorkoutsForDate(targetDate);

            verify(missedWorkoutRepository, never()).save(any(MissedWorkout.class));
        }

        @Test
        @DisplayName("Should not create duplicate missed workout when already exists")
        void detectAndLogMissedWorkoutsForDate_SkipsExisting() {
            LocalDate targetDate = LocalDate.now().minusDays(1);

            when(sessionRepository.findScheduledSessionsByDate(targetDate))
                    .thenReturn(List.of(testSession));
            when(progressRepository.countCompletedWorkoutsForSessionOnDate(
                    eq(1L), eq(1L), any(), any()))
                    .thenReturn(0L);
            when(missedWorkoutRepository.findByUserUserIdAndWorkoutSessionSessionId(1L, 1L))
                    .thenReturn(Optional.of(testMissedWorkout));

            missedWorkoutService.detectAndLogMissedWorkoutsForDate(targetDate);

            verify(missedWorkoutRepository, never()).save(any(MissedWorkout.class));
        }
    }

    @Nested
    @DisplayName("Generate Makeup Options Tests (UC-6.2)")
    class GenerateMakeupOptionsTests {

        @Test
        @DisplayName("Should generate four makeup options")
        void generateMakeupOptions_ReturnsFourOptions() {
            // Arrange
            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));

            // Act
            List<MakeupWorkoutOptionResponse> options = missedWorkoutService.generateMakeupOptions(1L, 1L);

            // Assert
            assertThat(options).hasSize(4);
            assertThat(options.stream().map(MakeupWorkoutOptionResponse::getOption))
                    .containsExactly(
                            MakeupOption.RESCHEDULE_NEXT_DAY,
                            MakeupOption.DISTRIBUTE_EXERCISES,
                            MakeupOption.WEEKEND_MAKEUP,
                            MakeupOption.EXTEND_PROGRAM
                    );
        }

        @Test
        @DisplayName("Should include session name in descriptions")
        void generateMakeupOptions_IncludesSessionName() {
            // Arrange
            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));

            // Act
            List<MakeupWorkoutOptionResponse> options = missedWorkoutService.generateMakeupOptions(1L, 1L);

            // Assert
            assertThat(options.get(0).getDetailedExplanation()).contains("Push Day");
        }

        @Test
        @DisplayName("Should throw exception when missed workout not found")
        void generateMakeupOptions_NotFound() {
            // Arrange
            when(missedWorkoutRepository.findById(999L)).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> missedWorkoutService.generateMakeupOptions(1L, 999L))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Missed workout not found");
        }
    }

    @Nested
    @DisplayName("Select Makeup Option Tests (UC-6.2)")
    class SelectMakeupOptionTests {

        @Test
        @DisplayName("Should successfully select reschedule option")
        void selectMakeupOption_Reschedule_Success() {
            // Arrange
            SelectMakeupOptionRequest request = SelectMakeupOptionRequest.builder()
                    .selectedOption(MakeupOption.RESCHEDULE_NEXT_DAY)
                    .build();

            CompensationAction savedAction = new CompensationAction();
            savedAction.setCompensationId(1L);
            savedAction.setMissedWorkout(testMissedWorkout);
            savedAction.setActionType("RESCHEDULE_NEXT_DAY");

            MakeupWorkout savedMakeup = new MakeupWorkout();
            savedMakeup.setMakeupId(1L);

            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));
            when(compensationRepository.save(any(CompensationAction.class))).thenReturn(savedAction);
            when(makeupRepository.save(any(MakeupWorkout.class))).thenReturn(savedMakeup);
            when(missedWorkoutRepository.save(any(MissedWorkout.class))).thenReturn(testMissedWorkout);

            // Act
            MissedWorkoutResponse response = missedWorkoutService.selectMakeupOption(1L, 1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(testMissedWorkout.getIsReplanned()).isTrue();
            assertThat(testMissedWorkout.getReplanStrategy()).isEqualTo("RESCHEDULE_NEXT_DAY");
            verify(compensationRepository, times(1)).save(any(CompensationAction.class));
            verify(makeupRepository, times(1)).save(any(MakeupWorkout.class));
        }

        @Test
        @DisplayName("Should create makeup workout for weekend option")
        void selectMakeupOption_WeekendMakeup_CreatesMakeupWorkout() {
            // Arrange
            SelectMakeupOptionRequest request = SelectMakeupOptionRequest.builder()
                    .selectedOption(MakeupOption.WEEKEND_MAKEUP)
                    .build();

            CompensationAction savedAction = new CompensationAction();
            savedAction.setCompensationId(1L);

            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));
            when(compensationRepository.save(any(CompensationAction.class))).thenReturn(savedAction);
            when(makeupRepository.save(any(MakeupWorkout.class))).thenAnswer(inv -> inv.getArgument(0));
            when(missedWorkoutRepository.save(any(MissedWorkout.class))).thenReturn(testMissedWorkout);

            // Act
            missedWorkoutService.selectMakeupOption(1L, 1L, request);

            // Assert
            verify(makeupRepository, times(1)).save(any(MakeupWorkout.class));
        }

        @Test
        @DisplayName("Should not create makeup workout for extend program option")
        void selectMakeupOption_ExtendProgram_NoMakeupWorkout() {
            // Arrange
            SelectMakeupOptionRequest request = SelectMakeupOptionRequest.builder()
                    .selectedOption(MakeupOption.EXTEND_PROGRAM)
                    .build();

            CompensationAction savedAction = new CompensationAction();
            savedAction.setCompensationId(1L);

            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));
            when(compensationRepository.save(any(CompensationAction.class))).thenReturn(savedAction);
            when(missedWorkoutRepository.save(any(MissedWorkout.class))).thenReturn(testMissedWorkout);

            // Act
            missedWorkoutService.selectMakeupOption(1L, 1L, request);

            // Assert
            verify(makeupRepository, never()).save(any(MakeupWorkout.class));
        }

        @Test
        @DisplayName("Should throw exception if already replanned")
        void selectMakeupOption_AlreadyReplanned() {
            // Arrange
            testMissedWorkout.setIsReplanned(true);

            SelectMakeupOptionRequest request = SelectMakeupOptionRequest.builder()
                    .selectedOption(MakeupOption.RESCHEDULE_NEXT_DAY)
                    .build();

            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));

            // Act & Assert
            assertThatThrownBy(() -> missedWorkoutService.selectMakeupOption(1L, 1L, request))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("already been replanned");
        }
    }

    @Nested
    @DisplayName("Reschedule Missed Workout Tests (UC-6.3)")
    class RescheduleMissedWorkoutTests {

        @Test
        @DisplayName("Should successfully reschedule missed workout")
        void rescheduleMissedWorkout_Success() {
            // Arrange
            RescheduleMissedWorkoutRequest request = RescheduleMissedWorkoutRequest.builder()
                    .newDate(LocalDate.now().plusDays(3))
                    .notes("Rescheduled to Saturday")
                    .build();

            CompensationAction savedAction = new CompensationAction();
            savedAction.setCompensationId(1L);

            when(missedWorkoutRepository.findById(1L)).thenReturn(Optional.of(testMissedWorkout));
            when(compensationRepository.save(any(CompensationAction.class))).thenReturn(savedAction);
            when(makeupRepository.save(any(MakeupWorkout.class))).thenAnswer(inv -> inv.getArgument(0));
            when(missedWorkoutRepository.save(any(MissedWorkout.class))).thenReturn(testMissedWorkout);

            // Act
            MissedWorkoutResponse response = missedWorkoutService.rescheduleMissedWorkout(1L, 1L, request);

            // Assert
            assertThat(response).isNotNull();
            assertThat(testMissedWorkout.getIsReplanned()).isTrue();
            assertThat(testMissedWorkout.getReplanStrategy()).isEqualTo("MANUAL_RESCHEDULE");
            verify(makeupRepository, times(1)).save(any(MakeupWorkout.class));
        }
    }

    @Nested
    @DisplayName("Get Missed Workouts Tests")
    class GetMissedWorkoutsTests {

        @Test
        @DisplayName("Should return paginated missed workouts")
        void getMissedWorkouts_Success() {
            // Arrange
            Pageable pageable = PageRequest.of(0, 10);
            List<MissedWorkout> missedWorkouts = List.of(testMissedWorkout);
            Page<MissedWorkout> page = new PageImpl<>(missedWorkouts, pageable, 1);

            when(missedWorkoutRepository.findByUserUserId(1L, pageable)).thenReturn(page);

            // Act
            Page<MissedWorkoutResponse> response = missedWorkoutService.getMissedWorkouts(1L, pageable);

            // Assert
            assertThat(response).isNotNull();
            assertThat(response.getTotalElements()).isEqualTo(1);
            assertThat(response.getContent().get(0).getSessionName()).isEqualTo("Push Day");
        }

        @Test
        @DisplayName("Should return unaddressed missed workouts")
        void getUnaddressedMissedWorkouts_Success() {
            // Arrange
            when(missedWorkoutRepository.findByUserUserIdAndIsReplannedFalse(1L))
                    .thenReturn(List.of(testMissedWorkout));

            // Act
            List<MissedWorkoutResponse> response = missedWorkoutService.getUnaddressedMissedWorkouts(1L);

            // Assert
            assertThat(response).hasSize(1);
            assertThat(response.get(0).getIsReplanned()).isFalse();
        }
    }

    @Nested
    @DisplayName("Missed Workout Report Tests (UC-6.4)")
    class MissedWorkoutReportTests {

        @Test
        @DisplayName("Should generate report with adherence percentage")
        void getMissedWorkoutReport_Success() {
            // Arrange
            LocalDate start = LocalDate.now().minusDays(30);
            LocalDate end = LocalDate.now();

            when(missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(eq(1L), any(), any()))
                    .thenReturn(3L);
            when(progressRepository.countByUserUserIdAndWorkoutDateBetween(eq(1L), any(), any()))
                    .thenReturn(12L);
            when(missedWorkoutRepository.countByUserUserIdAndIsReplannedTrue(1L))
                    .thenReturn(2L);
            when(missedWorkoutRepository.countByDayOfWeekForUser(eq(1L), any(), any()))
                    .thenReturn(List.<Object[]>of(new Object[]{1, 2})); // Sunday = 2
            when(missedWorkoutRepository.countByReasonForUser(eq(1L), any(), any()))
                    .thenReturn(List.<Object[]>of(new Object[]{"TOO_BUSY", 2}, new Object[]{"NO_MOTIVATION", 1}));

            // Act
            MissedWorkoutReportResponse report = missedWorkoutService.getMissedWorkoutReport(1L, start, end);

            // Assert
            assertThat(report).isNotNull();
            assertThat(report.getTotalMissedWorkouts()).isEqualTo(3);
            assertThat(report.getTotalCompletedWorkouts()).isEqualTo(12);
            assertThat(report.getAdherencePercentage()).isCloseTo(80.0f, within(0.1f)); // 12/(12+3) = 80%
            assertThat(report.getCompensationCompletionRate()).isEqualTo(66); // 2/3 = 66%
            assertThat(report.getPatterns()).isNotNull();
            assertThat(report.getRecommendations()).isNotEmpty();
        }

        @Test
        @DisplayName("Should handle case with no workouts")
        void getMissedWorkoutReport_NoWorkouts() {
            // Arrange
            when(missedWorkoutRepository.countByUserUserIdAndScheduledDateBetween(eq(1L), any(), any()))
                    .thenReturn(0L);
            when(progressRepository.countByUserUserIdAndWorkoutDateBetween(eq(1L), any(), any()))
                    .thenReturn(0L);
            when(missedWorkoutRepository.countByUserUserIdAndIsReplannedTrue(1L))
                    .thenReturn(0L);
            when(missedWorkoutRepository.countByDayOfWeekForUser(eq(1L), any(), any()))
                    .thenReturn(List.of());
            when(missedWorkoutRepository.countByReasonForUser(eq(1L), any(), any()))
                    .thenReturn(List.of());

            // Act
            MissedWorkoutReportResponse report = missedWorkoutService.getMissedWorkoutReport(1L, null, null);

            // Assert
            assertThat(report).isNotNull();
            assertThat(report.getTotalMissedWorkouts()).isEqualTo(0);
            assertThat(report.getAdherencePercentage()).isEqualTo(100.0f);
        }
    }

    private static org.assertj.core.data.Offset<Float> within(float value) {
        return org.assertj.core.data.Offset.offset(value);
    }
}
