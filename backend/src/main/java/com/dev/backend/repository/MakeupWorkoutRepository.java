package com.dev.backend.repository;

import com.dev.backend.model.entity.MakeupWorkout;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MakeupWorkoutRepository extends JpaRepository<MakeupWorkout, Long> {

    List<MakeupWorkout> findByCompensationActionMissedWorkoutUserUserIdAndIsCompletedFalse(Long userId);

    List<MakeupWorkout> findByOriginalSessionWorkoutPlanUserUserIdAndIsCompletedFalse(Long userId);
}
