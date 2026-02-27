package com.dev.backend.service.impl;

import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.request.RescheduleWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.model.entity.SessionExercise;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.WorkoutSession;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.SessionExerciseRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.repository.WorkoutPlanRepository;
import com.dev.backend.repository.WorkoutSessionRepository;
import com.dev.backend.service.WorkoutDateCalculator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class WorkoutPlanServiceImplTest {

    @Mock
    private WorkoutPlanRepository workoutPlanRepository;

    @Mock
    private WorkoutSessionRepository workoutSessionRepository;

    @Mock
    private SessionExerciseRepository sessionExerciseRepository;

    @Mock
    private GoalRepository goalRepository;

    @Mock
    private ExerciseRepository exerciseRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private WorkoutPlanMapper workoutPlanMapper;

    @Mock
    private WorkoutDateCalculator workoutDateCalculator;

    @InjectMocks
    private WorkoutPlanServiceImpl workoutPlanService;

    private WorkoutPlan testPlan;
    private WorkoutSession testSession;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setUserId(1L);

        LocalDate startDate = LocalDate.now();

        testPlan = new WorkoutPlan();
        testPlan.setPlanId(1L);
        testPlan.setUser(user);
        testPlan.setStartDate(startDate);
        testPlan.setDurationWeeks(4); // 4 weeks -> 28 days window

        testSession = new WorkoutSession();
        testSession.setSessionId(1L);
        testSession.setWorkoutPlan(testPlan);
        testSession.setSessionName("Push Day");
        testSession.setDayNumber(1);
        testSession.setIsRestDay(false);
    }

    @Nested
    @DisplayName("Reschedule Session Tests")
    class RescheduleSessionTests {

        @Test
        @DisplayName("Should successfully reschedule upcoming session within plan window")
        void rescheduleSession_Success() {
            LocalDate today = LocalDate.now();
            LocalDate currentDate = today.plusDays(2);
            LocalDate newDate = today.plusDays(5);

            testSession.setScheduledDate(currentDate);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));
            int expectedDayNumber = (int) ChronoUnit.DAYS.between(testPlan.getStartDate(), newDate) + 1;
            when(workoutSessionRepository.findAllByWorkoutPlanPlanIdAndDayNumber(1L, expectedDayNumber))
                    .thenReturn(Collections.emptyList());
            when(workoutSessionRepository.save(any(WorkoutSession.class)))
                    .thenAnswer(inv -> inv.getArgument(0));
            when(workoutPlanMapper.toSessionResponse(any(WorkoutSession.class)))
                    .thenAnswer(inv -> {
                        WorkoutSession s = inv.getArgument(0);
                        return WorkoutSessionResponse.builder()
                                .sessionId(s.getSessionId())
                                .scheduledDate(s.getScheduledDate())
                                .dayNumber(s.getDayNumber())
                                .build();
                    });

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            WorkoutSessionResponse response = workoutPlanService.rescheduleSession(1L, 1L, 1L, request);

            assertThat(response).isNotNull();
            assertThat(response.getScheduledDate()).isEqualTo(newDate);

            assertThat(response.getDayNumber()).isEqualTo(expectedDayNumber);

            verify(workoutSessionRepository, times(1)).save(eq(testSession));
        }

        @Test
        @DisplayName("Should swap with rest-day session when rescheduling onto a rest day")
        void rescheduleSession_SwapWithRestDay() {
            LocalDate today = LocalDate.now();
            LocalDate originalDate = today.plusDays(2);
            LocalDate newDate = today.plusDays(5);

            testSession.setScheduledDate(originalDate);
            testSession.setDayNumber(3);

            WorkoutSession restSession = new WorkoutSession();
            restSession.setSessionId(2L);
            restSession.setWorkoutPlan(testPlan);
            restSession.setSessionName("Rest Day");
            restSession.setDayNumber(6);
            restSession.setIsRestDay(true);
            restSession.setScheduledDate(newDate);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));

            int targetDayNumber = (int) ChronoUnit.DAYS.between(testPlan.getStartDate(), newDate) + 1;
            when(workoutSessionRepository.findAllByWorkoutPlanPlanIdAndDayNumber(1L, targetDayNumber))
                    .thenReturn(Collections.singletonList(restSession));

            when(workoutSessionRepository.save(any(WorkoutSession.class)))
                    .thenAnswer(inv -> inv.getArgument(0));
            when(workoutPlanMapper.toSessionResponse(any(WorkoutSession.class)))
                    .thenAnswer(inv -> {
                        WorkoutSession s = inv.getArgument(0);
                        return WorkoutSessionResponse.builder()
                                .sessionId(s.getSessionId())
                                .scheduledDate(s.getScheduledDate())
                                .dayNumber(s.getDayNumber())
                                .build();
                    });

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            WorkoutSessionResponse response = workoutPlanService.rescheduleSession(1L, 1L, 1L, request);

            assertThat(response.getScheduledDate()).isEqualTo(newDate);
            assertThat(response.getDayNumber()).isEqualTo(targetDayNumber);

            // Rest-day session should now occupy the original slot
            assertThat(restSession.getScheduledDate()).isEqualTo(originalDate);
            assertThat(restSession.getDayNumber()).isEqualTo(3);
        }

        @Test
        @DisplayName("Should reject reschedule when target day already has a workout session")
        void rescheduleSession_TargetDayHasWorkout_ThrowsBadRequest() {
            LocalDate today = LocalDate.now();
            LocalDate currentDate = today.plusDays(2);
            LocalDate newDate = today.plusDays(5);

            testSession.setScheduledDate(currentDate);
            testSession.setDayNumber(3);

            WorkoutSession existingWorkoutSession = new WorkoutSession();
            existingWorkoutSession.setSessionId(2L);
            existingWorkoutSession.setWorkoutPlan(testPlan);
            existingWorkoutSession.setSessionName("Leg Day");
            existingWorkoutSession.setDayNumber(6);
            existingWorkoutSession.setIsRestDay(false);
            existingWorkoutSession.setScheduledDate(newDate);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));

            int targetDayNumber = (int) ChronoUnit.DAYS.between(testPlan.getStartDate(), newDate) + 1;
            when(workoutSessionRepository.findAllByWorkoutPlanPlanIdAndDayNumber(1L, targetDayNumber))
                    .thenReturn(Collections.singletonList(existingWorkoutSession));

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("Target day already has a workout session");
        }

        @Test
        @DisplayName("Should reject reschedule when session is already in the past")
        void rescheduleSession_PastSession_ThrowsBadRequest() {
            LocalDate pastDate = LocalDate.now().minusDays(1);
            testSession.setScheduledDate(pastDate);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(LocalDate.now().plusDays(3))
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("already in the past");
        }

        @Test
        @DisplayName("Should reject reschedule when new date is before plan start")
        void rescheduleSession_NewDateBeforePlanStart_ThrowsBadRequest() {
            LocalDate today = LocalDate.now();
            LocalDate planStart = today;
            testPlan.setStartDate(planStart);
            testSession.setScheduledDate(today.plusDays(1));

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));

            LocalDate newDate = planStart.minusDays(1);
            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("before plan start date");
        }

        @Test
        @DisplayName("Should reject reschedule when new date is outside plan duration window")
        void rescheduleSession_NewDateAfterPlanEnd_ThrowsBadRequest() {
            LocalDate today = LocalDate.now();
            testPlan.setStartDate(today);
            testPlan.setDurationWeeks(1); // 7-day window
            testSession.setScheduledDate(today.plusDays(1));

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));

            LocalDate newDate = today.plusDays(10); // after 7-day window
            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("within the plan duration window");
        }

        @Test
        @DisplayName("Should throw ResourceNotFound when plan is not found for user")
        void rescheduleSession_PlanNotFound_ThrowsResourceNotFound() {
            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.empty());

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(LocalDate.now().plusDays(3))
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("WorkoutPlan");
        }

        @Test
        @DisplayName("Should throw ResourceNotFound when session is not found in plan")
        void rescheduleSession_SessionNotFound_ThrowsResourceNotFound() {
            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.empty());

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(LocalDate.now().plusDays(3))
                    .build();

            assertThatThrownBy(() -> workoutPlanService.rescheduleSession(1L, 1L, 1L, request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("WorkoutSession");
        }
    }

    @Nested
    @DisplayName("Session Exercise Update/Delete Tests")
    class SessionExerciseUpdateDeleteTests {

        @Test
        @DisplayName("Should update existing session exercise fields")
        void updateSessionExercise_Success() {
            SessionExercise sessionExercise = new SessionExercise();
            sessionExercise.setSessionExerciseId(10L);
            sessionExercise.setWorkoutSession(testSession);
            sessionExercise.setSets(3);
            sessionExercise.setRepetitions(10);

            Exercise exercise = new Exercise();
            exercise.setExerciseId(100L);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));
            when(sessionExerciseRepository.findById(10L))
                    .thenReturn(Optional.of(sessionExercise));
            when(exerciseRepository.findById(100L))
                    .thenReturn(Optional.of(exercise));
            when(workoutPlanMapper.toSessionResponse(any(WorkoutSession.class)))
                    .thenAnswer(inv -> {
                        WorkoutSession s = inv.getArgument(0);
                        return WorkoutSessionResponse.builder()
                                .sessionId(s.getSessionId())
                                .build();
                    });

            UpdateSessionExerciseRequest request = UpdateSessionExerciseRequest.builder()
                    .exerciseId(100L)
                    .sets(4)
                    .repetitions(8)
                    .build();

            WorkoutSessionResponse response = workoutPlanService.updateSessionExercise(1L, 1L, 1L, 10L, request);

            assertThat(response).isNotNull();
            assertThat(sessionExercise.getExercise()).isEqualTo(exercise);
            assertThat(sessionExercise.getSets()).isEqualTo(4);
            assertThat(sessionExercise.getRepetitions()).isEqualTo(8);
            verify(sessionExerciseRepository, times(1)).save(eq(sessionExercise));
        }

        @Test
        @DisplayName("Should throw BadRequest when session exercise does not belong to session on update")
        void updateSessionExercise_WrongSession_ThrowsBadRequest() {
            WorkoutSession otherSession = new WorkoutSession();
            otherSession.setSessionId(2L);

            SessionExercise sessionExercise = new SessionExercise();
            sessionExercise.setSessionExerciseId(10L);
            sessionExercise.setWorkoutSession(otherSession);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));
            when(sessionExerciseRepository.findById(10L))
                    .thenReturn(Optional.of(sessionExercise));

            UpdateSessionExerciseRequest request = UpdateSessionExerciseRequest.builder()
                    .sets(4)
                    .build();

            assertThatThrownBy(() -> workoutPlanService.updateSessionExercise(1L, 1L, 1L, 10L, request))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("does not belong to the specified session");
        }

        @Test
        @DisplayName("Should delete existing session exercise")
        void deleteSessionExercise_Success() {
            SessionExercise sessionExercise = new SessionExercise();
            sessionExercise.setSessionExerciseId(10L);
            sessionExercise.setWorkoutSession(testSession);

            testSession.setSessionExercises(Collections.singletonList(sessionExercise));

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));
            when(sessionExerciseRepository.findById(10L))
                    .thenReturn(Optional.of(sessionExercise));

            workoutPlanService.deleteSessionExercise(1L, 1L, 1L, 10L);

            verify(sessionExerciseRepository, times(1)).delete(eq(sessionExercise));
            assertThat(testSession.getSessionExercises()).isEmpty();
        }

        @Test
        @DisplayName("Should throw BadRequest when session exercise does not belong to session on delete")
        void deleteSessionExercise_WrongSession_ThrowsBadRequest() {
            WorkoutSession otherSession = new WorkoutSession();
            otherSession.setSessionId(2L);

            SessionExercise sessionExercise = new SessionExercise();
            sessionExercise.setSessionExerciseId(10L);
            sessionExercise.setWorkoutSession(otherSession);

            when(workoutPlanRepository.findByPlanIdAndUserUserId(1L, 1L))
                    .thenReturn(Optional.of(testPlan));
            when(workoutSessionRepository.findBySessionIdAndWorkoutPlanPlanId(1L, 1L))
                    .thenReturn(Optional.of(testSession));
            when(sessionExerciseRepository.findById(10L))
                    .thenReturn(Optional.of(sessionExercise));

            assertThatThrownBy(() -> workoutPlanService.deleteSessionExercise(1L, 1L, 1L, 10L))
                    .isInstanceOf(BadRequestException.class)
                    .hasMessageContaining("does not belong to the specified session");
        }
    }
}

