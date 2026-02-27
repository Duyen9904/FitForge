import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_workout_plan_state.freezed.dart';

/// Holds the draft data for each session while the user builds the plan
class SessionDraft {
  String sessionName;
  int dayNumber;
  String? focusArea;
  int? estimatedDuration;
  bool isRestDay;
  List<ExerciseDraft> exercises;

  SessionDraft({
    required this.sessionName,
    required this.dayNumber,
    this.focusArea,
    this.estimatedDuration,
    this.isRestDay = false,
    List<ExerciseDraft>? exercises,
  }) : exercises = exercises ?? [];
}

/// Holds draft data for an exercise within a session
class ExerciseDraft {
  int exerciseId;
  String exerciseName;
  String? imageUrl;
  int sets;
  int repetitions;
  double? weightKg;
  int? restTimeSeconds;
  String? notes;

  ExerciseDraft({
    required this.exerciseId,
    required this.exerciseName,
    this.imageUrl,
    this.sets = 3,
    this.repetitions = 10,
    this.weightKg,
    this.restTimeSeconds = 60,
    this.notes,
  });
}

/// State for the create workout plan wizard
@freezed
class CreateWorkoutPlanState with _$CreateWorkoutPlanState {
  const factory CreateWorkoutPlanState.editing({
    @Default(0) int currentStep,
    // Step 1 - Plan details (prefilled for easy testing)
    @Default('Full Body Strength') String planName,
    @Default('A balanced strength training plan targeting all major muscle groups') String description,
    @Default(1) int? goalId,
    @Default(null) int? muscleGroupId,
    @Default('INTERMEDIATE') String difficultyLevel,
    @Default(3) int frequencyPerWeek,
    @Default(4) int durationWeeks,
    @Default(null) DateTime? startDate,
    // Step 2 & 3 - Sessions with exercises
    @Default([]) List<SessionDraft> sessions,
  }) = CreateWorkoutPlanEditing;
  
  const factory CreateWorkoutPlanState.submitting({
    @Default('Creating workout plan...') String message,
  }) = CreateWorkoutPlanSubmitting;

  const factory CreateWorkoutPlanState.success({
    required int planId,
  }) = CreateWorkoutPlanSuccess;

  const factory CreateWorkoutPlanState.error({
    required String message,
  }) = CreateWorkoutPlanError;
}
