package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.CreateExerciseRequest;
import com.dev.backend.model.dto.response.EquipmentResponse;
import com.dev.backend.model.dto.response.ExerciseAlternativeResponse;
import com.dev.backend.model.dto.response.ExerciseResponse;
import com.dev.backend.model.dto.response.ExerciseSuggestionResponse;
import com.dev.backend.model.dto.response.ExerciseSummaryResponse;
import com.dev.backend.model.dto.response.MuscleGroupResponse;
import com.dev.backend.model.entity.Equipment;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.ExerciseAlternative;
import com.dev.backend.model.entity.MuscleGroup;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface ExerciseMapper extends BaseMapper<Exercise, CreateExerciseRequest, ExerciseResponse> {

    @Override
    @Mapping(target = "primaryMuscleGroups", expression = "java(extractPrimaryMuscleGroups(exercise))")
    @Mapping(target = "secondaryMuscleGroups", expression = "java(extractSecondaryMuscleGroups(exercise))")
    @Mapping(target = "equipment", expression = "java(extractEquipment(exercise))")
    ExerciseResponse toResponse(Exercise exercise);

    @Override
    @Mapping(target = "difficultyLevel", expression = "java(request.getDifficultyLevel() != null ? request.getDifficultyLevel().name() : null)")
    @Mapping(target = "exerciseType", expression = "java(request.getExerciseType() != null ? request.getExerciseType().name() : null)")
    @Mapping(target = "requiresSpotter", expression = "java(request.getRequiresSpotter() != null ? request.getRequiresSpotter() : false)")
    Exercise toEntity(CreateExerciseRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "difficultyLevel", expression = "java(request.getDifficultyLevel() != null ? request.getDifficultyLevel().name() : entity.getDifficultyLevel())")
    @Mapping(target = "exerciseType", expression = "java(request.getExerciseType() != null ? request.getExerciseType().name() : entity.getExerciseType())")
    void updateEntityFromRequest(@MappingTarget Exercise entity, CreateExerciseRequest request);

    ExerciseSummaryResponse toSummaryResponse(Exercise exercise);

    MuscleGroupResponse toMuscleGroupResponse(MuscleGroup muscleGroup);

    EquipmentResponse toEquipmentResponse(Equipment equipment);

    @Mapping(target = "alternativeExercise", source = "alternativeExercise")
    ExerciseAlternativeResponse toAlternativeResponse(ExerciseAlternative alternative);

    @Mapping(target = "defaultSets", constant = "3")
    @Mapping(target = "defaultReps", constant = "10")
    @Mapping(target = "defaultWeightKg", constant = "20.0")
    @Mapping(target = "defaultRestSeconds", constant = "60")
    ExerciseSuggestionResponse toSuggestionResponse(Exercise exercise);

    default List<MuscleGroupResponse> extractPrimaryMuscleGroups(Exercise exercise) {
        if (exercise == null || exercise.getExerciseMuscleGroups() == null) {
            return Collections.emptyList();
        }
        return exercise.getExerciseMuscleGroups().stream()
                .filter(emg -> Boolean.TRUE.equals(emg.getIsPrimary()))
                .map(emg -> toMuscleGroupResponse(emg.getMuscleGroup()))
                .collect(Collectors.toList());
    }

    default List<MuscleGroupResponse> extractSecondaryMuscleGroups(Exercise exercise) {
        if (exercise == null || exercise.getExerciseMuscleGroups() == null) {
            return Collections.emptyList();
        }
        return exercise.getExerciseMuscleGroups().stream()
                .filter(emg -> !Boolean.TRUE.equals(emg.getIsPrimary()))
                .map(emg -> toMuscleGroupResponse(emg.getMuscleGroup()))
                .collect(Collectors.toList());
    }

    default List<EquipmentResponse> extractEquipment(Exercise exercise) {
        if (exercise == null || exercise.getExerciseEquipments() == null) {
            return Collections.emptyList();
        }
        return exercise.getExerciseEquipments().stream()
                .map(ee -> toEquipmentResponse(ee.getEquipment()))
                .collect(Collectors.toList());
    }
}
