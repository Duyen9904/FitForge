package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateExerciseRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.*;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ExerciseMapper {

    public ExerciseResponse toResponse(Exercise exercise) {
        List<MuscleGroupResponse> primaryMuscles = Collections.emptyList();
        List<MuscleGroupResponse> secondaryMuscles = Collections.emptyList();

        if (exercise.getExerciseMuscleGroups() != null) {
            primaryMuscles = exercise.getExerciseMuscleGroups().stream()
                    .filter(emg -> Boolean.TRUE.equals(emg.getIsPrimary()))
                    .map(emg -> toMuscleGroupResponse(emg.getMuscleGroup()))
                    .collect(Collectors.toList());

            secondaryMuscles = exercise.getExerciseMuscleGroups().stream()
                    .filter(emg -> !Boolean.TRUE.equals(emg.getIsPrimary()))
                    .map(emg -> toMuscleGroupResponse(emg.getMuscleGroup()))
                    .collect(Collectors.toList());
        }

        List<EquipmentResponse> equipment = Collections.emptyList();
        if (exercise.getExerciseEquipments() != null) {
            equipment = exercise.getExerciseEquipments().stream()
                    .map(ee -> toEquipmentResponse(ee.getEquipment()))
                    .collect(Collectors.toList());
        }

        return ExerciseResponse.builder()
                .exerciseId(exercise.getExerciseId())
                .exerciseName(exercise.getExerciseName())
                .description(exercise.getDescription())
                .difficultyLevel(exercise.getDifficultyLevel())
                .exerciseType(exercise.getExerciseType())
                .instructions(exercise.getInstructions())
                .videoUrl(exercise.getVideoUrl())
                .imageUrl(exercise.getImageUrl())
                .caloriesBurnedPerMin(exercise.getCaloriesBurnedPerMin())
                .requiresSpotter(exercise.getRequiresSpotter())
                .equipmentCategory(exercise.getEquipmentCategory())
                .primaryMuscleGroups(primaryMuscles)
                .secondaryMuscleGroups(secondaryMuscles)
                .equipment(equipment)
                .build();
    }

    public ExerciseSummaryResponse toSummaryResponse(Exercise exercise) {
        return ExerciseSummaryResponse.builder()
                .exerciseId(exercise.getExerciseId())
                .exerciseName(exercise.getExerciseName())
                .description(exercise.getDescription())
                .difficultyLevel(exercise.getDifficultyLevel())
                .exerciseType(exercise.getExerciseType())
                .imageUrl(exercise.getImageUrl())
                .caloriesBurnedPerMin(exercise.getCaloriesBurnedPerMin())
                .build();
    }

    public MuscleGroupResponse toMuscleGroupResponse(MuscleGroup muscleGroup) {
        if (muscleGroup == null) return null;
        return MuscleGroupResponse.builder()
                .muscleGroupId(muscleGroup.getMuscleGroupId())
                .groupName(muscleGroup.getGroupName())
                .category(muscleGroup.getCategory())
                .description(muscleGroup.getDescription())
                .recoveryDaysNeeded(muscleGroup.getRecoveryDaysNeeded())
                .imageUrl(muscleGroup.getImageUrl())
                .build();
    }

    public EquipmentResponse toEquipmentResponse(Equipment equipment) {
        if (equipment == null) return null;
        return EquipmentResponse.builder()
                .equipmentId(equipment.getEquipmentId())
                .equipmentName(equipment.getEquipmentName())
                .equipmentType(equipment.getEquipmentType())
                .description(equipment.getDescription())
                .imageUrl(equipment.getImageUrl())
                .build();
    }

    public ExerciseAlternativeResponse toAlternativeResponse(ExerciseAlternative alternative) {
        return ExerciseAlternativeResponse.builder()
                .alternativeId(alternative.getAlternativeId())
                .alternativeExercise(toSummaryResponse(alternative.getAlternativeExercise()))
                .reason(alternative.getReason())
                .substitutionType(alternative.getSubstitutionType())
                .build();
    }

    public Exercise toEntity(CreateExerciseRequest request) {
        Exercise exercise = new Exercise();
        exercise.setExerciseName(request.getExerciseName());
        exercise.setDescription(request.getDescription());
        exercise.setDifficultyLevel(request.getDifficultyLevel().name());
        exercise.setExerciseType(request.getExerciseType().name());
        exercise.setInstructions(request.getInstructions());
        exercise.setVideoUrl(request.getVideoUrl());
        exercise.setImageUrl(request.getImageUrl());
        exercise.setCaloriesBurnedPerMin(request.getCaloriesBurnedPerMin());
        exercise.setRequiresSpotter(request.getRequiresSpotter() != null ? request.getRequiresSpotter() : false);
        exercise.setEquipmentCategory(request.getEquipmentCategory());
        return exercise;
    }
}
