package com.dev.backend.service.impl;

import com.dev.backend.config.CacheNames;
import com.dev.backend.exception.DuplicateResourceException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.ExerciseMapper;
import com.dev.backend.model.dto.request.CreateExerciseRequest;
import com.dev.backend.model.dto.request.ExerciseFilterRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import com.dev.backend.model.enums.ExerciseType;
import com.dev.backend.model.enums.TargetMuscleGroup;
import com.dev.backend.repository.*;
import com.dev.backend.service.ExerciseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ExerciseServiceImpl implements ExerciseService {

    private final ExerciseRepository exerciseRepository;
    private final MuscleGroupRepository muscleGroupRepository;
    private final EquipmentRepository equipmentRepository;
    private final WorkoutFavoriteRepository workoutFavoriteRepository;
    private final ExerciseAlternativeRepository exerciseAlternativeRepository;
    private final UserRepository userRepository;
    private final ExerciseMapper exerciseMapper;

    public ExerciseServiceImpl(ExerciseRepository exerciseRepository,
                               MuscleGroupRepository muscleGroupRepository,
                               EquipmentRepository equipmentRepository,
                               WorkoutFavoriteRepository workoutFavoriteRepository,
                               ExerciseAlternativeRepository exerciseAlternativeRepository,
                               UserRepository userRepository,
                               ExerciseMapper exerciseMapper) {
        this.exerciseRepository = exerciseRepository;
        this.muscleGroupRepository = muscleGroupRepository;
        this.equipmentRepository = equipmentRepository;
        this.workoutFavoriteRepository = workoutFavoriteRepository;
        this.exerciseAlternativeRepository = exerciseAlternativeRepository;
        this.userRepository = userRepository;
        this.exerciseMapper = exerciseMapper;
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ExerciseSummaryResponse> browseExercises(ExerciseFilterRequest filter, Pageable pageable) {
        log.info("Browsing exercises with filter: {}", filter);

        Specification<Exercise> spec = buildSpecification(filter);
        Page<Exercise> exercises = exerciseRepository.findAll(spec, pageable);

        return exercises.map(exerciseMapper::toSummaryResponse);
    }

    private Specification<Exercise> buildSpecification(ExerciseFilterRequest filter) {
        return (root, query, criteriaBuilder) -> {
            List<jakarta.persistence.criteria.Predicate> predicates = new ArrayList<>();

            if (filter != null) {
                if (filter.getDifficultyLevel() != null) {
                    predicates.add(criteriaBuilder.equal(root.get("difficultyLevel"), filter.getDifficultyLevel().name()));
                }

                if (filter.getExerciseType() != null) {
                    predicates.add(criteriaBuilder.equal(root.get("exerciseType"), filter.getExerciseType().name()));
                }

                if (filter.getRequiresSpotter() != null) {
                    predicates.add(criteriaBuilder.equal(root.get("requiresSpotter"), filter.getRequiresSpotter()));
                }

                if (filter.getSearchQuery() != null && !filter.getSearchQuery().isBlank()) {
                    String searchPattern = "%" + filter.getSearchQuery().toLowerCase() + "%";
                    predicates.add(criteriaBuilder.like(criteriaBuilder.lower(root.get("exerciseName")), searchPattern));
                }

                // Note: muscle group and equipment filtering would require joins
                // For complex filtering, consider using a custom query
            }

            return criteriaBuilder.and(predicates.toArray(new jakarta.persistence.criteria.Predicate[0]));
        };
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = CacheNames.EXERCISE_BY_ID, keyGenerator = "customKeyGenerator")
    public ExerciseResponse getExerciseById(Long exerciseId) {
        log.info("Getting exercise details for ID: {}", exerciseId);
        Exercise exercise = exerciseRepository.findByIdWithMuscleGroups(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        // Initialize equipment collection in the same persistence context
        exerciseRepository.findByIdWithEquipments(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        ExerciseResponse response = exerciseMapper.toResponse(exercise);

        // Add alternatives
        List<ExerciseAlternative> alternatives = exerciseAlternativeRepository.findByOriginalExerciseId(exerciseId);
        response.setAlternatives(alternatives.stream()
                .map(exerciseMapper::toAlternativeResponse)
                .collect(Collectors.toList()));

        return response;
    }

    @Override
    @Transactional
    public void addToFavorites(Long userId, Long exerciseId) {
        log.info("Adding exercise {} to favorites for user {}", exerciseId, userId);

        if (workoutFavoriteRepository.existsByUserUserIdAndExerciseExerciseId(userId, exerciseId)) {
            log.info("Exercise {} is already in favorites for user {}", exerciseId, userId);
            return; // Already favorited, no action needed
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        WorkoutFavorite favorite = new WorkoutFavorite();
        favorite.setUser(user);
        favorite.setExercise(exercise);
        favorite.setFavoritedAt(Instant.now());

        workoutFavoriteRepository.save(favorite);
        log.info("Added exercise {} to favorites for user {}", exerciseId, userId);
    }

    @Override
    @Transactional
    public void removeFromFavorites(Long userId, Long exerciseId) {
        log.info("Removing exercise {} from favorites for user {}", exerciseId, userId);

        workoutFavoriteRepository.deleteByUserUserIdAndExerciseExerciseId(userId, exerciseId);
        log.info("Removed exercise {} from favorites for user {}", exerciseId, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ExerciseSummaryResponse> getUserFavorites(Long userId, Pageable pageable) {
        log.info("Getting favorite exercises for user {}", userId);

        Page<WorkoutFavorite> favorites = workoutFavoriteRepository.findByUserIdWithExercises(userId, pageable);

        List<ExerciseSummaryResponse> responses = favorites.getContent().stream()
                .map(fav -> exerciseMapper.toSummaryResponse(fav.getExercise()))
                .collect(Collectors.toList());

        return new PageImpl<>(responses, pageable, favorites.getTotalElements());
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isFavorite(Long userId, Long exerciseId) {
        return workoutFavoriteRepository.existsByUserUserIdAndExerciseExerciseId(userId, exerciseId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExerciseAlternativeResponse> getAlternatives(Long exerciseId) {
        log.info("Getting alternatives for exercise {}", exerciseId);

        // Verify exercise exists
        if (!exerciseRepository.existsById(exerciseId)) {
            throw new ResourceNotFoundException("Exercise", "id", exerciseId);
        }

        List<ExerciseAlternative> alternatives = exerciseAlternativeRepository.findByOriginalExerciseId(exerciseId);

        return alternatives.stream()
                .map(exerciseMapper::toAlternativeResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheNames.EXERCISES, allEntries = true)
    public ExerciseResponse createExercise(CreateExerciseRequest request) {
        log.info("Creating new exercise: {}", request.getExerciseName());

        if (exerciseRepository.existsByExerciseName(request.getExerciseName())) {
            throw new DuplicateResourceException("Exercise", "name", request.getExerciseName());
        }

        Exercise exercise = exerciseMapper.toEntity(request);
        exercise = exerciseRepository.save(exercise);

        // Add muscle groups
        if (request.getPrimaryMuscleGroupIds() != null) {
            for (Long muscleGroupId : request.getPrimaryMuscleGroupIds()) {
                MuscleGroup muscleGroup = muscleGroupRepository.findById(muscleGroupId)
                        .orElseThrow(() -> new ResourceNotFoundException("MuscleGroup", "id", muscleGroupId));
                ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                emg.setExercise(exercise);
                emg.setMuscleGroup(muscleGroup);
                emg.setIsPrimary(true);
                exercise.getExerciseMuscleGroups().add(emg);
            }
        }

        if (request.getSecondaryMuscleGroupIds() != null) {
            for (Long muscleGroupId : request.getSecondaryMuscleGroupIds()) {
                MuscleGroup muscleGroup = muscleGroupRepository.findById(muscleGroupId)
                        .orElseThrow(() -> new ResourceNotFoundException("MuscleGroup", "id", muscleGroupId));
                ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                emg.setExercise(exercise);
                emg.setMuscleGroup(muscleGroup);
                emg.setIsPrimary(false);
                exercise.getExerciseMuscleGroups().add(emg);
            }
        }

        // Add equipment
        if (request.getEquipmentIds() != null) {
            for (Long equipmentId : request.getEquipmentIds()) {
                Equipment equipment = equipmentRepository.findById(equipmentId)
                        .orElseThrow(() -> new ResourceNotFoundException("Equipment", "id", equipmentId));
                ExerciseEquipment ee = new ExerciseEquipment();
                ee.setExercise(exercise);
                ee.setEquipment(equipment);
                exercise.getExerciseEquipments().add(ee);
            }
        }

        exercise = exerciseRepository.save(exercise);
        log.info("Created exercise with ID: {}", exercise.getExerciseId());

        return exerciseMapper.toResponse(exercise);
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = CacheNames.MUSCLE_GROUPS, keyGenerator = "customKeyGenerator")
    public List<MuscleGroupResponse> getAllMuscleGroups() {
        log.info("Getting all muscle groups");
        return muscleGroupRepository.findAll().stream()
                .map(exerciseMapper::toMuscleGroupResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = CacheNames.EQUIPMENT, keyGenerator = "customKeyGenerator")
    public List<EquipmentResponse> getAllEquipment() {
        log.info("Getting all equipment");
        return equipmentRepository.findAll().stream()
                .map(exerciseMapper::toEquipmentResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = CacheNames.EQUIPMENT, keyGenerator = "customKeyGenerator")
    public EquipmentResponse getEquipmentById(Long equipmentId) {
        log.info("Getting equipment details for ID: {}", equipmentId);
        Equipment equipment = equipmentRepository.findById(equipmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment", "id", equipmentId));
        return exerciseMapper.toEquipmentResponse(equipment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExerciseTypeResponse> getAllExerciseTypes() {
        log.info("Getting all exercise types with counts");
        return Arrays.stream(ExerciseType.values())
                .map(type -> {
                    long count = exerciseRepository.countByExerciseType(type.name());
                    return ExerciseTypeResponse.builder()
                            .typeName(type.name())
                            .exerciseCount(count)
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExerciseCategoryResponse> getAllExerciseCategories() {
        log.info("Getting all exercise categories with counts");
        return Arrays.stream(TargetMuscleGroup.values())
                .map(category -> {
                    long count = exerciseRepository.countByMuscleGroupCategory(category.name());
                    return ExerciseCategoryResponse.builder()
                            .categoryName(category.name())
                            .exerciseCount(count)
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ExerciseSummaryResponse> getExercisesByMuscleGroup(Long muscleGroupId, Pageable pageable) {
        log.info("Getting exercises for muscle group: {}", muscleGroupId);

        if (!muscleGroupRepository.existsById(muscleGroupId)) {
            throw new ResourceNotFoundException("MuscleGroup", "id", muscleGroupId);
        }

        return exerciseRepository.findByMuscleGroupId(muscleGroupId, pageable)
                .map(exerciseMapper::toSummaryResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ExerciseSummaryResponse> getExercisesByEquipment(Long equipmentId, Pageable pageable) {
        log.info("Getting exercises for equipment: {}", equipmentId);

        if (!equipmentRepository.existsById(equipmentId)) {
            throw new ResourceNotFoundException("Equipment", "id", equipmentId);
        }

        return exerciseRepository.findByEquipmentId(equipmentId, pageable)
                .map(exerciseMapper::toSummaryResponse);
    }

    // ============= Admin Methods (UC-16.1) =============

    @Override
    @Transactional
    @Caching(evict = {
        @CacheEvict(value = CacheNames.EXERCISES, allEntries = true),
        @CacheEvict(value = CacheNames.EXERCISE_BY_ID, allEntries = true),
        @CacheEvict(value = CacheNames.MUSCLE_GROUPS, allEntries = true),
        @CacheEvict(value = CacheNames.EQUIPMENT, allEntries = true)
    })
    public ExerciseResponse updateExercise(Long exerciseId, com.dev.backend.model.dto.request.UpdateExerciseRequest request) {
        log.info("Updating exercise: {}", exerciseId);

        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        // Update basic fields if provided
        if (request.getExerciseName() != null) {
            if (!exercise.getExerciseName().equals(request.getExerciseName()) &&
                exerciseRepository.existsByExerciseName(request.getExerciseName())) {
                throw new DuplicateResourceException("Exercise", "name", request.getExerciseName());
            }
            exercise.setExerciseName(request.getExerciseName());
        }
        if (request.getDescription() != null) {
            exercise.setDescription(request.getDescription());
        }
        if (request.getInstructions() != null) {
            exercise.setInstructions(request.getInstructions());
        }
        if (request.getVideoUrl() != null) {
            exercise.setVideoUrl(request.getVideoUrl());
        }
        if (request.getImageUrl() != null) {
            exercise.setImageUrl(request.getImageUrl());
        }
        if (request.getDifficultyLevel() != null) {
            exercise.setDifficultyLevel(request.getDifficultyLevel());
        }
        if (request.getExerciseType() != null) {
            exercise.setExerciseType(request.getExerciseType());
        }

        // Update muscle groups if provided
        if (request.getMuscleGroupIds() != null) {
            exercise.getExerciseMuscleGroups().clear();
            for (Long muscleGroupId : request.getMuscleGroupIds()) {
                MuscleGroup muscleGroup = muscleGroupRepository.findById(muscleGroupId)
                        .orElseThrow(() -> new ResourceNotFoundException("MuscleGroup", "id", muscleGroupId));
                ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
                emg.setExercise(exercise);
                emg.setMuscleGroup(muscleGroup);
                emg.setIsPrimary(true);
                exercise.getExerciseMuscleGroups().add(emg);
            }
        }

        // Update equipment if provided
        if (request.getEquipmentIds() != null) {
            exercise.getExerciseEquipments().clear();
            for (Long equipmentId : request.getEquipmentIds()) {
                Equipment equipment = equipmentRepository.findById(equipmentId)
                        .orElseThrow(() -> new ResourceNotFoundException("Equipment", "id", equipmentId));
                ExerciseEquipment ee = new ExerciseEquipment();
                ee.setExercise(exercise);
                ee.setEquipment(equipment);
                exercise.getExerciseEquipments().add(ee);
            }
        }

        exercise = exerciseRepository.save(exercise);
        log.info("Updated exercise: {}", exerciseId);

        return exerciseMapper.toResponse(exercise);
    }

    @Override
    @Transactional
    @Caching(evict = {
        @CacheEvict(value = CacheNames.EXERCISES, allEntries = true),
        @CacheEvict(value = CacheNames.EXERCISE_BY_ID, allEntries = true),
        @CacheEvict(value = CacheNames.MUSCLE_GROUPS, allEntries = true),
        @CacheEvict(value = CacheNames.EQUIPMENT, allEntries = true)
    })
    public void deleteExercise(Long exerciseId) {
        log.info("Deleting exercise: {}", exerciseId);

        Exercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        if (isExerciseInUse(exerciseId)) {
            throw new IllegalStateException("Cannot delete exercise that is in use in workout sessions");
        }

        // Remove from favorites first
        workoutFavoriteRepository.deleteByExerciseExerciseId(exerciseId);

        // Remove exercise alternatives
        exerciseAlternativeRepository.deleteByOriginalExerciseId(exerciseId);
        exerciseAlternativeRepository.deleteByAlternativeExerciseId(exerciseId);

        exerciseRepository.delete(exercise);
        log.info("Deleted exercise: {}", exerciseId);
    }

    @Override
    @Transactional
    public void addAlternativeExercise(Long exerciseId, Long alternativeExerciseId, String reason) {
        log.info("Adding alternative {} to exercise {}", alternativeExerciseId, exerciseId);

        Exercise originalExercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", exerciseId));

        Exercise alternativeExercise = exerciseRepository.findById(alternativeExerciseId)
                .orElseThrow(() -> new ResourceNotFoundException("Exercise", "id", alternativeExerciseId));

        // Check if alternative already exists
        if (exerciseAlternativeRepository.existsByOriginalExerciseIdAndAlternativeExerciseId(
                exerciseId, alternativeExerciseId)) {
            log.info("Alternative already exists");
            return;
        }

        ExerciseAlternative alternative = new ExerciseAlternative();
        alternative.setOriginalExercise(originalExercise);
        alternative.setAlternativeExercise(alternativeExercise);
        alternative.setReason(reason);

        exerciseAlternativeRepository.save(alternative);
        log.info("Added alternative {} to exercise {}", alternativeExerciseId, exerciseId);
    }

    @Override
    @Transactional
    public void removeAlternativeExercise(Long exerciseId, Long alternativeExerciseId) {
        log.info("Removing alternative {} from exercise {}", alternativeExerciseId, exerciseId);

        exerciseAlternativeRepository.deleteByOriginalExerciseIdAndAlternativeExerciseId(
                exerciseId, alternativeExerciseId);
        log.info("Removed alternative {} from exercise {}", alternativeExerciseId, exerciseId);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isExerciseInUse(Long exerciseId) {
        // Check if exercise is used in any session exercises
        return exerciseRepository.isExerciseInUse(exerciseId);
    }
}
