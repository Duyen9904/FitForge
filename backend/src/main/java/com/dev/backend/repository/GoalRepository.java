package com.dev.backend.repository;

import com.dev.backend.model.entity.Goal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GoalRepository extends JpaRepository<Goal, Long> {

    Optional<Goal> findByGoalName(String goalName);

    boolean existsByGoalName(String goalName);
}
