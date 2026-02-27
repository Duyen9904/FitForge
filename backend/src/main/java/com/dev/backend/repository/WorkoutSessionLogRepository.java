package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutSessionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface WorkoutSessionLogRepository extends JpaRepository<WorkoutSessionLog, Long> {

    List<WorkoutSessionLog> findByUserUserIdOrderByPerformedAtDesc(Long userId);

    List<WorkoutSessionLog> findByUserUserIdAndPerformedAtBetween(Long userId, Instant start, Instant end);

    @Query("SELECT AVG(s.completionRate) FROM WorkoutSessionLog s WHERE s.user.userId = :userId " +
           "AND s.workoutPlan.planId = :planId AND s.performedAt >= :since")
    Float avgCompletionRate(@Param("userId") Long userId, @Param("planId") Long planId, @Param("since") Instant since);

    @Query("SELECT AVG(s.avgRPE) FROM WorkoutSessionLog s WHERE s.user.userId = :userId " +
           "AND s.workoutPlan.planId = :planId AND s.performedAt >= :since")
    Float avgRPE(@Param("userId") Long userId, @Param("planId") Long planId, @Param("since") Instant since);

    @Query("SELECT COUNT(s) FROM WorkoutSessionLog s WHERE s.user.userId = :userId " +
           "AND s.workoutPlan.planId = :planId AND s.performedAt >= :since")
    Long countSessionsSince(@Param("userId") Long userId, @Param("planId") Long planId, @Param("since") Instant since);
}
