package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface WorkoutSessionRepository extends JpaRepository<WorkoutSession, Long> {

    List<WorkoutSession> findByWorkoutPlanPlanIdOrderByDayNumber(Long planId);

    Optional<WorkoutSession> findBySessionIdAndWorkoutPlanPlanId(Long sessionId, Long planId);

    @Query("SELECT ws FROM WorkoutSession ws " +
           "LEFT JOIN FETCH ws.sessionExercises se " +
           "LEFT JOIN FETCH se.exercise " +
           "WHERE ws.sessionId = :sessionId")
    Optional<WorkoutSession> findByIdWithExercises(@Param("sessionId") Long sessionId);

    @Query("SELECT ws FROM WorkoutSession ws " +
           "WHERE ws.workoutPlan.planId = :planId AND ws.dayNumber = :dayNumber")
    Optional<WorkoutSession> findByPlanIdAndDayNumber(
            @Param("planId") Long planId,
            @Param("dayNumber") Integer dayNumber);

    /**
     * Load all sessions for a given plan and day number.
     * Used by reschedule logic to detect conflicts and rest-day swaps.
     */
    List<WorkoutSession> findAllByWorkoutPlanPlanIdAndDayNumber(Long planId, Integer dayNumber);

    void deleteByWorkoutPlanPlanId(Long planId);

    @Query("SELECT ws FROM WorkoutSession ws " +
           "WHERE ws.scheduledDate = :date AND ws.isRestDay = false " +
           "AND ws.workoutPlan.isActive = true")
    List<WorkoutSession> findScheduledSessionsByDate(@Param("date") LocalDate date);

    @Query("SELECT ws FROM WorkoutSession ws " +
           "WHERE ws.scheduledDate BETWEEN :startDate AND :endDate " +
           "AND ws.isRestDay = false " +
           "AND ws.workoutPlan.isActive = true " +
           "AND ws.workoutPlan.user.userId = :userId")
    List<WorkoutSession> findScheduledSessionsByUserAndDateRange(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
