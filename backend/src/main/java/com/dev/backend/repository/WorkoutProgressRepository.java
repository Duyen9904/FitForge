package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutProgress;
import com.dev.backend.model.projection.DailyWorkoutAggregate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface WorkoutProgressRepository extends JpaRepository<WorkoutProgress, Long> {

    Page<WorkoutProgress> findByUserUserId(Long userId, Pageable pageable);

    Optional<WorkoutProgress> findByProgressIdAndUserUserId(Long progressId, Long userId);

    @Query("SELECT wp FROM WorkoutProgress wp " +
           "LEFT JOIN FETCH wp.exerciseLogs el " +
           "LEFT JOIN FETCH el.exercise " +
           "WHERE wp.progressId = :progressId AND wp.user.userId = :userId")
    Optional<WorkoutProgress> findByIdWithExerciseLogs(@Param("progressId") Long progressId, 
                                                        @Param("userId") Long userId);

    @Query("SELECT wp FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId " +
           "AND wp.workoutDate BETWEEN :startDate AND :endDate " +
           "ORDER BY wp.workoutDate DESC")
    List<WorkoutProgress> findByUserIdAndDateRange(@Param("userId") Long userId,
                                                    @Param("startDate") Instant startDate,
                                                    @Param("endDate") Instant endDate);

    @Query("SELECT wp FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.completed = false " +
           "ORDER BY wp.startTime DESC")
    Optional<WorkoutProgress> findInProgressWorkout(@Param("userId") Long userId);

    @Query("SELECT COUNT(wp) FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.completed = true")
    long countCompletedByUserId(@Param("userId") Long userId);

    @Query("SELECT SUM(wp.caloriesBurned) FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.completed = true " +
           "AND wp.workoutDate BETWEEN :startDate AND :endDate")
    Integer getTotalCaloriesBurned(@Param("userId") Long userId,
                                   @Param("startDate") Instant startDate,
                                   @Param("endDate") Instant endDate);

    boolean existsByUserUserIdAndCompletedFalse(Long userId);

    @Query("SELECT COUNT(wp) FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.completed = true " +
           "AND wp.workoutDate BETWEEN :startDate AND :endDate")
    long countByUserUserIdAndWorkoutDateBetween(@Param("userId") Long userId,
                                                 @Param("startDate") Instant startDate,
                                                 @Param("endDate") Instant endDate);

    @Query("SELECT CAST(wp.workoutDate AS LocalDate) as workoutDate, " +
           "COUNT(wp) as totalWorkouts, " +
           "SUM(wp.durationMinutes) as totalMinutes, " +
           "SUM(wp.caloriesBurned) as totalCalories " +
           "FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId " +
           "AND wp.completed = true " +
           "AND CAST(wp.workoutDate AS LocalDate) BETWEEN :startDate AND :endDate " +
           "GROUP BY CAST(wp.workoutDate AS LocalDate) " +
           "ORDER BY CAST(wp.workoutDate AS LocalDate)")
    List<DailyWorkoutAggregate> getDailyWorkoutTotals(@Param("userId") Long userId,
                                                       @Param("startDate") LocalDate startDate,
                                                       @Param("endDate") LocalDate endDate);

    @Query("SELECT wp.workoutSession.sessionId FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.workoutPlan.planId = :planId AND wp.completed = true")
    List<Long> findCompletedSessionIdsByUserAndPlan(@Param("userId") Long userId, @Param("planId") Long planId);

    @Query("SELECT COUNT(wp) FROM WorkoutProgress wp " +
           "WHERE wp.user.userId = :userId AND wp.workoutSession.sessionId = :sessionId " +
           "AND wp.completed = true AND wp.workoutDate BETWEEN :start AND :end")
    long countCompletedWorkoutsForSessionOnDate(@Param("userId") Long userId,
                                                @Param("sessionId") Long sessionId,
                                                @Param("start") Instant start,
                                                @Param("end") Instant end);
}
