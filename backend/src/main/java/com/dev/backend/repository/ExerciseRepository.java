package com.dev.backend.repository;

import com.dev.backend.model.entity.Exercise;
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
public interface ExerciseRepository extends JpaRepository<Exercise, Long>, JpaSpecificationExecutor<Exercise> {

    Optional<Exercise> findByExerciseName(String exerciseName);

    boolean existsByExerciseName(String exerciseName);

    @Query("SELECT e FROM Exercise e " +
           "LEFT JOIN FETCH e.exerciseMuscleGroups emg " +
           "LEFT JOIN FETCH emg.muscleGroup " +
           "WHERE e.exerciseId = :exerciseId")
    Optional<Exercise> findByIdWithMuscleGroups(@Param("exerciseId") Long exerciseId);

    @Query("SELECT e FROM Exercise e " +
           "LEFT JOIN FETCH e.exerciseEquipments ee " +
           "LEFT JOIN FETCH ee.equipment " +
           "WHERE e.exerciseId = :exerciseId")
    Optional<Exercise> findByIdWithEquipments(@Param("exerciseId") Long exerciseId);

    @Query("SELECT DISTINCT e FROM Exercise e " +
           "JOIN e.exerciseMuscleGroups emg " +
           "WHERE emg.muscleGroup.muscleGroupId = :muscleGroupId")
    Page<Exercise> findByMuscleGroupId(@Param("muscleGroupId") Long muscleGroupId, Pageable pageable);

    @Query("SELECT DISTINCT e FROM Exercise e " +
           "JOIN e.exerciseEquipments ee " +
           "WHERE ee.equipment.equipmentId = :equipmentId")
    Page<Exercise> findByEquipmentId(@Param("equipmentId") Long equipmentId, Pageable pageable);

    @Query("SELECT e FROM Exercise e WHERE LOWER(e.exerciseName) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<Exercise> searchByName(@Param("query") String query, Pageable pageable);

    List<Exercise> findByDifficultyLevel(String difficultyLevel);

    List<Exercise> findByExerciseType(String exerciseType);

    long countByExerciseType(String exerciseType);

    @Query("SELECT COUNT(DISTINCT e) FROM Exercise e " +
           "JOIN e.exerciseMuscleGroups emg " +
           "WHERE emg.muscleGroup.category = :category")
    long countByMuscleGroupCategory(@Param("category") String category);

    /**
     * Check if exercise is used in any workout session (UC-16.1)
     */
    @Query("SELECT CASE WHEN COUNT(se) > 0 THEN true ELSE false END FROM SessionExercise se WHERE se.exercise.exerciseId = :exerciseId")
    boolean isExerciseInUse(@Param("exerciseId") Long exerciseId);
}
