package com.dev.backend.repository;

import com.dev.backend.model.entity.WorkoutFavorite;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface WorkoutFavoriteRepository extends JpaRepository<WorkoutFavorite, Long> {

    Page<WorkoutFavorite> findByUserUserId(Long userId, Pageable pageable);

    Optional<WorkoutFavorite> findByUserUserIdAndExerciseExerciseId(Long userId, String exerciseId);

    boolean existsByUserUserIdAndExerciseExerciseId(Long userId, String exerciseId);

    void deleteByUserUserIdAndExerciseExerciseId(Long userId, String exerciseId);

    @Query("SELECT wf FROM WorkoutFavorite wf " +
           "LEFT JOIN FETCH wf.exercise e " +
           "WHERE wf.user.userId = :userId")
    Page<WorkoutFavorite> findByUserIdWithExercises(@Param("userId") Long userId, Pageable pageable);

    long countByUserUserId(Long userId);

    /**
     * Delete all favorites for an exercise (UC-16.1)
     */
    void deleteByExerciseExerciseId(String exerciseId);
}
