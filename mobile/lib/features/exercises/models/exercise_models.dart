import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_models.freezed.dart';
part 'exercise_models.g.dart';

/// Exercise summary for list view (UC-4.1)
@freezed
class ExerciseSummary with _$ExerciseSummary {
  const factory ExerciseSummary({
    required int exerciseId,
    required String exerciseName,
    required String description,
    required String difficultyLevel,
    required String exerciseType,
    String? imageUrl,
    int? caloriesBurnedPerMin,
  }) = _ExerciseSummary;

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSummaryFromJson(json);
}

/// Full exercise details (UC-4.2)
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required int exerciseId,
    required String exerciseName,
    required String description,
    required String difficultyLevel,
    required String exerciseType,
    required String instructions,
    String? videoUrl,
    String? imageUrl,
    int? caloriesBurnedPerMin,
    @Default(false) bool requiresSpotter,
    String? equipmentCategory,
    @Default([]) List<MuscleGroup> primaryMuscleGroups,
    @Default([]) List<MuscleGroup> secondaryMuscleGroups,
    @Default([]) List<Equipment> equipment,
    @Default([]) List<ExerciseAlternative> alternatives,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// Muscle group information
@freezed
class MuscleGroup with _$MuscleGroup {
  const factory MuscleGroup({
    required int muscleGroupId,
    required String groupName,
    required String category,
    String? description,
    int? recoveryDaysNeeded,
  }) = _MuscleGroup;

  factory MuscleGroup.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupFromJson(json);
}

/// Equipment information
@freezed
class Equipment with _$Equipment {
  const factory Equipment({
    required int equipmentId,
    required String equipmentName,
    required String equipmentType,
    String? description,
  }) = _Equipment;

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);
}

/// Alternative exercise information (UC-4.4)
@freezed
class ExerciseAlternative with _$ExerciseAlternative {
  const factory ExerciseAlternative({
    required int alternativeId,
    required ExerciseSummary alternativeExercise,
    String? reason,
    String? substitutionType,
  }) = _ExerciseAlternative;

  factory ExerciseAlternative.fromJson(Map<String, dynamic> json) =>
      _$ExerciseAlternativeFromJson(json);
}

/// Exercise recommendation (UC-12.3)
@freezed
class ExerciseRecommendation with _$ExerciseRecommendation {
  const factory ExerciseRecommendation({
    required int exerciseId,
    required String exerciseName,
    required String description,
    required String difficultyLevel,
    required String exerciseType,
    String? primaryMuscleGroup,
    String? rationale,
    int? relevanceScore,
  }) = _ExerciseRecommendation;

  factory ExerciseRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRecommendationFromJson(json);
}

/// Pagination wrapper for Spring Page responses
@Freezed(genericArgumentFactories: true)
class PageData<T> with _$PageData<T> {
  const factory PageData({
    @Default([]) List<T> content,
    @Default(0) int page,
    @Default(20) int size,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(true) bool first,
    @Default(true) bool last,
  }) = _PageData;

  factory PageData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PageDataFromJson(json, fromJsonT);
}
