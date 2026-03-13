package com.dev.backend.repository;

import com.dev.backend.model.entity.ExercisePerformanceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface ExercisePerformanceLogRepository extends JpaRepository<ExercisePerformanceLog, Long> {

    @Query("SELECT p FROM ExercisePerformanceLog p WHERE p.sessionLog.user.userId = :userId " +
           "AND p.exercise.exerciseId = :exerciseId ORDER BY p.sessionLog.performedAt DESC")
    List<ExercisePerformanceLog> findByUserAndExercise(@Param("userId") Long userId, @Param("exerciseId") String exerciseId);

    @Query("SELECT p FROM ExercisePerformanceLog p WHERE p.sessionLog.user.userId = :userId " +
           "AND p.painFlag = true AND p.sessionLog.performedAt >= :since")
    List<ExercisePerformanceLog> findPainFlagsSince(@Param("userId") Long userId, @Param("since") Instant since);
}
