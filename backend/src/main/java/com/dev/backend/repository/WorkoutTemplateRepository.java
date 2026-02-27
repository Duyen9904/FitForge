package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkoutTemplateRepository extends JpaRepository<WorkoutTemplate, Long> {

    List<WorkoutTemplate> findByIsActiveTrueOrderByNameAsc();

    List<WorkoutTemplate> findByGoalTypeAndIsActiveTrue(String goalType);

    List<WorkoutTemplate> findByExperienceLevelAndIsActiveTrue(String experienceLevel);

    List<WorkoutTemplate> findByGoalTypeAndExperienceLevelAndIsActiveTrue(String goalType, String experienceLevel);
}
