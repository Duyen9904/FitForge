package com.dev.backend.repository;

import com.dev.backend.model.entity.CompensationAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repository for compensation actions (UC-11)
 */
@Repository
public interface CompensationActionRepository extends JpaRepository<CompensationAction, Long> {

    // Existing queries
    List<CompensationAction> findByCheatMealLogUserUserIdAndIsCompletedFalse(Long userId);

    List<CompensationAction> findByMissedWorkoutUserUserIdAndIsCompletedFalse(Long userId);

    List<CompensationAction> findByCheatMealLogCheatMealLogId(Long cheatMealLogId);

    List<CompensationAction> findByMissedWorkoutMissedWorkoutId(Long missedWorkoutId);

    /**
     * Find pending compensations that are past their valid date (for expiration)
     */
    @Query("SELECT c FROM CompensationAction c WHERE c.status = 'ACTIVE' AND c.validUntilDate < :today")
    List<CompensationAction> findExpiredCompensations(@Param("today") LocalDate today);
}

