package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutPlan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WorkoutPlanRepository extends JpaRepository<WorkoutPlan, Long>, JpaSpecificationExecutor<WorkoutPlan> {

    Page<WorkoutPlan> findByUserUserId(Long userId, Pageable pageable);

    Page<WorkoutPlan> findByUserUserIdAndIsActiveTrue(Long userId, Pageable pageable);

    Optional<WorkoutPlan> findByPlanIdAndUserUserId(Long planId, Long userId);

    List<WorkoutPlan> findByUserUserIdAndIsActiveTrue(Long userId);

    @Query("SELECT DISTINCT wp FROM WorkoutPlan wp " +
           "LEFT JOIN FETCH wp.workoutSessions ws " +
           "LEFT JOIN FETCH ws.sessionExercises se " +
           "LEFT JOIN FETCH se.exercise " +
           "WHERE wp.planId = :planId AND wp.user.userId = :userId")
    Optional<WorkoutPlan> findByIdWithSessionsAndExercises(
            @Param("planId") Long planId, 
            @Param("userId") Long userId);

    @Query("SELECT COUNT(wp) FROM WorkoutPlan wp WHERE wp.user.userId = :userId")
    long countByUserId(@Param("userId") Long userId);

    boolean existsByPlanIdAndUserUserId(Long planId, Long userId);

    @Query("SELECT COUNT(wp) FROM WorkoutPlan wp WHERE wp.user.userId = :userId AND wp.isActive = true")
    long countActivePlansByUserId(@Param("userId") Long userId);

    /**
     * Check if a goal is used by any workout plan (UC-16.2)
     */
    boolean existsByGoalGoalId(Long goalId);
}
