package com.dev.backend.service;

import com.dev.backend.model.dto.request.CreateExerciseRequest;
import com.dev.backend.model.dto.request.ExerciseFilterRequest;
import com.dev.backend.model.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface ExerciseService {

    /**
     * Browse exercises with optional filters (UC-4.1)
     */
    Page<ExerciseSummaryResponse> browseExercises(ExerciseFilterRequest filter, Pageable pageable);

    /**
     * Get exercise details (UC-4.2)
     */
    ExerciseResponse getExerciseById(String exerciseId);

    /**
     * Add exercise to favorites (UC-4.3)
     */
    void addToFavorites(Long userId, String exerciseId);

    /**
     * Remove exercise from favorites (UC-4.3)
     */
    void removeFromFavorites(Long userId, String exerciseId);

    /**
     * Get user's favorite exercises
     */
    Page<ExerciseSummaryResponse> getUserFavorites(Long userId, Pageable pageable);

    /**
     * Check if exercise is in user's favorites
     */
    boolean isFavorite(Long userId, String exerciseId);

    /**
     * Get alternative exercises (UC-4.4)
     */
    List<ExerciseAlternativeResponse> getAlternatives(String exerciseId);

    /**
     * Create a new exercise - admin only (UC-4.5)
     */
    ExerciseResponse createExercise(CreateExerciseRequest request);

    /**
     * Get all muscle groups
     */
    List<MuscleGroupResponse> getAllMuscleGroups();

    /**
     * Get all equipment
     */
    List<EquipmentResponse> getAllEquipment();

    /**
     * Get equipment details by ID
     */
    EquipmentResponse getEquipmentById(Long equipmentId);

    /**
     * Get all exercise types with exercise counts
     */
    List<ExerciseTypeResponse> getAllExerciseTypes();

    /**
     * Get all exercise categories with exercise counts
     */
    List<ExerciseCategoryResponse> getAllExerciseCategories();

    /**
     * Get exercises by muscle group
     */
    Page<ExerciseSummaryResponse> getExercisesByMuscleGroup(Long muscleGroupId, Pageable pageable);

    /**
     * Get exercises by equipment
     */
    Page<ExerciseSummaryResponse> getExercisesByEquipment(Long equipmentId, Pageable pageable);

    // ============= Admin Methods (UC-16.1) =============

    /**
     * Update an existing exercise - admin only (UC-16.1)
     */
    ExerciseResponse updateExercise(String exerciseId, com.dev.backend.model.dto.request.UpdateExerciseRequest request);

    /**
     * Delete an exercise - admin only (UC-16.1)
     * @throws IllegalStateException if exercise is in use
     */
    void deleteExercise(String exerciseId);

    /**
     * Add an alternative exercise - admin only (UC-16.1)
     */
    void addAlternativeExercise(String exerciseId, String alternativeExerciseId, String reason);

    /**
     * Remove an alternative exercise - admin only (UC-16.1)
     */
    void removeAlternativeExercise(String exerciseId, String alternativeExerciseId);

    /**
     * Check if an exercise is in use (in workout sessions or plans)
     */
    boolean isExerciseInUse(String exerciseId);
}
