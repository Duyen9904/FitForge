package com.dev.backend.repository;

import com.dev.backend.model.entity.ExerciseAlternative;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExerciseAlternativeRepository extends JpaRepository<ExerciseAlternative, Long> {

    @Query("SELECT ea FROM ExerciseAlternative ea " +
           "LEFT JOIN FETCH ea.alternativeExercise " +
           "WHERE ea.originalExercise.exerciseId = :exerciseId")
    List<ExerciseAlternative> findByOriginalExerciseId(@Param("exerciseId") Long exerciseId);

    boolean existsByOriginalExerciseExerciseIdAndAlternativeExerciseExerciseId(Long originalId, Long alternativeId);

    /**
     * Check if alternative exists (simplified method name for UC-16.1)
     */
    @Query("SELECT CASE WHEN COUNT(ea) > 0 THEN true ELSE false END FROM ExerciseAlternative ea " +
           "WHERE ea.originalExercise.exerciseId = :originalId " +
           "AND ea.alternativeExercise.exerciseId = :alternativeId")
    boolean existsByOriginalExerciseIdAndAlternativeExerciseId(
            @Param("originalId") Long originalId, 
            @Param("alternativeId") Long alternativeId);

    /**
     * Delete all alternatives for an exercise (UC-16.1)
     */
    @Modifying
    @Query("DELETE FROM ExerciseAlternative ea WHERE ea.originalExercise.exerciseId = :exerciseId")
    void deleteByOriginalExerciseId(@Param("exerciseId") Long exerciseId);

    /**
     * Delete all alternatives referencing an exercise (UC-16.1)
     */
    @Modifying
    @Query("DELETE FROM ExerciseAlternative ea WHERE ea.alternativeExercise.exerciseId = :exerciseId")
    void deleteByAlternativeExerciseId(@Param("exerciseId") Long exerciseId);

    /**
     * Delete specific alternative relationship (UC-16.1)
     */
    @Modifying
    @Query("DELETE FROM ExerciseAlternative ea " +
           "WHERE ea.originalExercise.exerciseId = :originalId " +
           "AND ea.alternativeExercise.exerciseId = :alternativeId")
    void deleteByOriginalExerciseIdAndAlternativeExerciseId(
            @Param("originalId") Long originalId, 
            @Param("alternativeId") Long alternativeId);
}
