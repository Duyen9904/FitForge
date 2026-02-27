package com.dev.backend.repository;

import com.dev.backend.model.entity.ExerciseLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface ExerciseLogRepository extends JpaRepository<ExerciseLog, Long> {

    List<ExerciseLog> findByWorkoutProgressProgressIdOrderBySetNumber(Long progressId);

    @Query("SELECT el FROM ExerciseLog el " +
           "WHERE el.exercise.exerciseId = :exerciseId " +
           "AND el.workoutProgress.user.userId = :userId " +
           "AND el.workoutProgress.workoutDate BETWEEN :startDate AND :endDate " +
           "ORDER BY el.workoutProgress.workoutDate")
    List<ExerciseLog> findByExerciseAndUserAndDateRange(@Param("exerciseId") Long exerciseId,
                                                         @Param("userId") Long userId,
                                                         @Param("startDate") Instant startDate,
                                                         @Param("endDate") Instant endDate);

    @Query("SELECT el FROM ExerciseLog el " +
           "WHERE el.workoutProgress.user.userId = :userId " +
           "AND el.exercise.exerciseId = :exerciseId " +
           "AND el.completed = true " +
           "ORDER BY el.weightUsedKg DESC")
    List<ExerciseLog> findTopWeightByUserAndExercise(@Param("userId") Long userId,
                                                      @Param("exerciseId") Long exerciseId);

    @Query("SELECT MAX(el.weightUsedKg) FROM ExerciseLog el " +
           "WHERE el.workoutProgress.user.userId = :userId " +
           "AND el.exercise.exerciseId = :exerciseId " +
           "AND el.completed = true")
    Float findMaxWeightByUserAndExercise(@Param("userId") Long userId,
                                          @Param("exerciseId") Long exerciseId);

    void deleteByWorkoutProgressProgressId(Long progressId);
}
