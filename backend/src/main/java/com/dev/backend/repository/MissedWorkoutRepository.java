package com.dev.backend.repository;

import com.dev.backend.model.entity.MissedWorkout;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface MissedWorkoutRepository extends JpaRepository<MissedWorkout, Long> {

    List<MissedWorkout> findByUserUserIdOrderByScheduledDateDesc(Long userId);

    Page<MissedWorkout> findByUserUserId(Long userId, Pageable pageable);

    List<MissedWorkout> findByUserUserIdAndIsReplannedFalse(Long userId);

    long countByUserUserIdAndScheduledDateBetween(Long userId, LocalDate start, LocalDate end);

    Optional<MissedWorkout> findByUserUserIdAndWorkoutSessionSessionId(Long userId, Long sessionId);

    @Query("SELECT mw.reason, COUNT(mw) FROM MissedWorkout mw " +
           "WHERE mw.user.userId = :userId AND mw.scheduledDate BETWEEN :start AND :end " +
           "GROUP BY mw.reason")
    List<Object[]> countByReasonForUser(@Param("userId") Long userId,
                                        @Param("start") LocalDate start,
                                        @Param("end") LocalDate end);

    @Query("SELECT FUNCTION('DAYOFWEEK', mw.scheduledDate), COUNT(mw) FROM MissedWorkout mw " +
           "WHERE mw.user.userId = :userId AND mw.scheduledDate BETWEEN :start AND :end " +
           "GROUP BY FUNCTION('DAYOFWEEK', mw.scheduledDate)")
    List<Object[]> countByDayOfWeekForUser(@Param("userId") Long userId,
                                           @Param("start") LocalDate start,
                                           @Param("end") LocalDate end);

    long countByUserUserIdAndIsReplannedTrue(Long userId);
}
