package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.CompensationStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class CompensationMapperTest {

    private CompensationMapper compensationMapper;

    @BeforeEach
    void setUp() {
        compensationMapper = new CompensationMapper();
    }

    @Nested
    @DisplayName("toCompensationResponse tests")
    class ToCompensationResponseTests {

        @Test
        @DisplayName("Should map cheat meal compensation correctly")
        void toCompensationResponse_CheatMeal() {
            User user = new User();
            user.setUserId(1L);

            CheatMealLog cheatMeal = new CheatMealLog();
            cheatMeal.setCheatMealLogId(1L);
            cheatMeal.setUser(user);

            CompensationAction entity = new CompensationAction();
            entity.setCompensationId(1L);
            entity.setCheatMealLog(cheatMeal);
            entity.setMissedWorkout(null);
            entity.setStatus(CompensationStatus.ACTIVE);
            entity.setActionType("REDUCE_CALORIES");
            entity.setActionDescription("Reduce daily calories by 200 for 3 days");
            entity.setScheduledDate(LocalDate.of(2026, 1, 16));
            entity.setValidUntilDate(LocalDate.of(2026, 1, 19));
            entity.setIsCompleted(false);
            entity.setCalorieAdjustment(-200);
            entity.setDetails("Focus on protein-rich meals");
            entity.setCreatedAt(Instant.now());

            CompensationActionResponse response = compensationMapper.toCompensationResponse(entity);

            assertThat(response.getCompensationId()).isEqualTo(1L);
            assertThat(response.getTriggerType()).isEqualTo("CHEAT_MEAL");
            assertThat(response.getStatus()).isEqualTo("ACTIVE");
            assertThat(response.getStatusDisplayName()).isEqualTo("Active");
            assertThat(response.getActionType()).isEqualTo("REDUCE_CALORIES");
            assertThat(response.getScheduledDate()).isEqualTo(LocalDate.of(2026, 1, 16));
            assertThat(response.getCalorieAdjustment()).isEqualTo(-200);
            assertThat(response.getIsCompleted()).isFalse();
        }

        @Test
        @DisplayName("Should map missed workout compensation correctly")
        void toCompensationResponse_MissedWorkout() {
            User user = new User();
            user.setUserId(1L);

            MissedWorkout missedWorkout = new MissedWorkout();
            missedWorkout.setMissedWorkoutId(1L);
            missedWorkout.setUser(user);

            CompensationAction entity = new CompensationAction();
            entity.setCompensationId(2L);
            entity.setCheatMealLog(null);
            entity.setMissedWorkout(missedWorkout);
            entity.setStatus(CompensationStatus.PENDING);
            entity.setActionType("RESCHEDULE_WORKOUT");

            CompensationActionResponse response = compensationMapper.toCompensationResponse(entity);

            assertThat(response.getTriggerType()).isEqualTo("MISSED_WORKOUT");
            assertThat(response.getStatus()).isEqualTo("PENDING");
        }
    }

    @Nested
    @DisplayName("toOptionResponse tests")
    class ToOptionResponseTests {

        @Test
        @DisplayName("Should map to option response with recommendation")
        void toOptionResponse_Recommended() {
            CompensationAction entity = new CompensationAction();
            entity.setCompensationId(1L);
            entity.setActionType("ADD_CARDIO");
            entity.setActionDescription("Add 30 minutes of cardio");
            entity.setCalorieAdjustment(-300);
            entity.setScheduledDate(LocalDate.of(2026, 1, 16));
            entity.setValidUntilDate(LocalDate.of(2026, 1, 16));

            CompensationOptionResponse response = compensationMapper.toOptionResponse(
                    entity, true, "Best option based on your activity level");

            assertThat(response.getCompensationId()).isEqualTo(1L);
            assertThat(response.getActionType()).isEqualTo("ADD_CARDIO");
            assertThat(response.getActionTypeDisplayName()).isEqualTo("ADD CARDIO");
            assertThat(response.getCalorieAdjustment()).isEqualTo(-300);
            assertThat(response.getDurationDays()).isEqualTo(1);
            assertThat(response.getIsRecommended()).isTrue();
            assertThat(response.getRecommendationReason()).isEqualTo("Best option based on your activity level");
        }

        @Test
        @DisplayName("Should calculate duration correctly for multi-day compensation")
        void toOptionResponse_MultiDay() {
            CompensationAction entity = new CompensationAction();
            entity.setCompensationId(1L);
            entity.setActionType("REDUCE_CALORIES");
            entity.setScheduledDate(LocalDate.of(2026, 1, 15));
            entity.setValidUntilDate(LocalDate.of(2026, 1, 20));

            CompensationOptionResponse response = compensationMapper.toOptionResponse(
                    entity, false, null);

            assertThat(response.getDurationDays()).isEqualTo(6); // Jan 15-20 = 6 days
        }

        @Test
        @DisplayName("Should handle null dates with default duration")
        void toOptionResponse_NullDates() {
            CompensationAction entity = new CompensationAction();
            entity.setCompensationId(1L);
            entity.setActionType("ADD_WORKOUT");
            entity.setScheduledDate(null);
            entity.setValidUntilDate(null);

            CompensationOptionResponse response = compensationMapper.toOptionResponse(
                    entity, false, null);

            assertThat(response.getDurationDays()).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("toMakeupWorkoutResponse tests")
    class ToMakeupWorkoutResponseTests {

        @Test
        @DisplayName("Should map makeup workout correctly")
        void toMakeupWorkoutResponse_MapsCorrectly() {
            WorkoutSession originalSession = new WorkoutSession();
            originalSession.setSessionId(1L);
            originalSession.setSessionName("Leg Day");

            WorkoutSession replacementSession = new WorkoutSession();
            replacementSession.setSessionId(2L);
            replacementSession.setSessionName("Modified Leg Day");

            CompensationAction compensation = new CompensationAction();
            compensation.setCompensationId(1L);

            MakeupWorkout entity = new MakeupWorkout();
            entity.setMakeupId(1L);
            entity.setCompensationAction(compensation);
            entity.setOriginalSession(originalSession);
            entity.setReplacementSession(replacementSession);
            entity.setScheduledMakeupDate(LocalDate.of(2026, 1, 18));
            entity.setAdjustmentType("RESCHEDULE");
            entity.setAdjustmentNotes("Moved to Saturday due to schedule conflict");
            entity.setIsCompleted(false);

            MakeupWorkoutResponse response = compensationMapper.toMakeupWorkoutResponse(entity);

            assertThat(response.getMakeupId()).isEqualTo(1L);
            assertThat(response.getOriginalSessionId()).isEqualTo(1L);
            assertThat(response.getOriginalSessionName()).isEqualTo("Leg Day");
            assertThat(response.getReplacementSessionId()).isEqualTo(2L);
            assertThat(response.getScheduledMakeupDate()).isEqualTo(LocalDate.of(2026, 1, 18));
            assertThat(response.getAdjustmentType()).isEqualTo("RESCHEDULE");
            assertThat(response.getIsCompleted()).isFalse();
        }

        @Test
        @DisplayName("Should handle null replacement session")
        void toMakeupWorkoutResponse_NullReplacement() {
            WorkoutSession originalSession = new WorkoutSession();
            originalSession.setSessionId(1L);
            originalSession.setSessionName("Push Day");

            MakeupWorkout entity = new MakeupWorkout();
            entity.setMakeupId(1L);
            entity.setOriginalSession(originalSession);
            entity.setReplacementSession(null);
            entity.setScheduledMakeupDate(LocalDate.of(2026, 1, 20));
            entity.setAdjustmentType("DISTRIBUTE");
            entity.setIsCompleted(false);

            MakeupWorkoutResponse response = compensationMapper.toMakeupWorkoutResponse(entity);

            assertThat(response.getReplacementSessionId()).isNull();
        }
    }
}
