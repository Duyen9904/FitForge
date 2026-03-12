import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/exercises/models/exercise_models.dart';

import '../../../shared/enums/reschedule_reason.dart';
import '../../../shared/enums/target_muscle_group.dart';

part 'workout_plan_models.freezed.dart';
part 'workout_plan_models.g.dart';

// ========================= RESPONSE MODELS =========================

/// Workout template summary for recommended templates
@freezed
class WorkoutTemplateSummaryResponse with _$WorkoutTemplateSummaryResponse {
  const factory WorkoutTemplateSummaryResponse({
    required int id,
    required String name,
    String? goalType,
    String? experienceLevel,
    int? daysPerWeek,
    String? equipmentTags,
    String? recommendationReason,
  }) = _WorkoutTemplateSummaryResponse;

  factory WorkoutTemplateSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateSummaryResponseFromJson(json);
}

/// Full workout plan response (from GET /workout-plans/{planId})
@freezed
class WorkoutPlanResponse with _$WorkoutPlanResponse {
  const factory WorkoutPlanResponse({
    required int planId,
    required String planName,
    String? description,
    GoalResponse? goal,
    MuscleGroup? muscleGroup,
    int? frequencyPerWeek,
    int? durationWeeks,
    String? difficultyLevel,
    String? startDate,

    // Recommendation metadata
    String? algorithmVersion,
    String? generatedFrom,
    int? version,
    String? recommendationReason,

    @Default(false) bool aiGenerated,
    @Default(true) bool allowWorkoutSwaps,
    @Default(true) bool isActive,
    String? createdAt,
    String? updatedAt,
    @Default([]) List<String> scheduledWorkoutDates,
    @Default([]) List<WorkoutSessionResponse> sessions,
  }) = _WorkoutPlanResponse;

  factory WorkoutPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanResponseFromJson(json);
}

/// Workout plan summary for list views (from GET /workout-plans)
@freezed
class WorkoutPlanSummaryResponse with _$WorkoutPlanSummaryResponse {
  const factory WorkoutPlanSummaryResponse({
    required int planId,
    required String planName,
    String? description,
    GoalResponse? goal,
    MuscleGroup? muscleGroup,
    int? frequencyPerWeek,
    int? durationWeeks,
    String? difficultyLevel,
    @Default(false) bool aiGenerated,
    @Default(true) bool isActive,
    int? sessionCount,
    String? createdAt,
    String? updatedAt,
  }) = _WorkoutPlanSummaryResponse;

  factory WorkoutPlanSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanSummaryResponseFromJson(json);
}

/// Goal information within a workout plan
@freezed
class GoalResponse with _$GoalResponse {
  const factory GoalResponse({
    required int goalId,
    required String goalName,
    String? description,
    String? recommendedRepRange,
    String? recommendedRestTime,
    String? recommendedFrequency,
    int? targetCalorieAdjustment,
  }) = _GoalResponse;

  factory GoalResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseFromJson(json);
}

/// Workout session within a plan
@freezed
class WorkoutSessionResponse with _$WorkoutSessionResponse {
  const factory WorkoutSessionResponse({
    required int sessionId,
    required String sessionName,
    required int dayNumber,
    DateTime? scheduledDate,
    String? focusArea,
    int? estimatedDuration,
    String? warmUpNotes,
    String? coolDownNotes,
    @Default(false) bool isRestDay,
    @Default(false) bool isCompleted,
    int? missedWorkoutId,
    @Default(false) bool isMissed,
    @Default(0) int exerciseCount,
    @Default([]) List<SessionExerciseResponse> exercises,
  }) = _WorkoutSessionResponse;

  factory WorkoutSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionResponseFromJson(json);
}

/// Exercise within a session
@freezed
class SessionExerciseResponse with _$SessionExerciseResponse {
  const factory SessionExerciseResponse({
    required int sessionExerciseId,
    WorkoutExerciseSummary? exercise,
    int? sets,
    int? repetitions,
    double? weightKg,
    int? restTimeSeconds,
    int? orderIndex,
    String? notes,
    @Default(false) bool isSuperset,
  }) = _SessionExerciseResponse;

  factory SessionExerciseResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionExerciseResponseFromJson(json);
}

/// Exercise summary within a workout session
@freezed
class WorkoutExerciseSummary with _$WorkoutExerciseSummary {
  const factory WorkoutExerciseSummary({
    required String exerciseId,
    required String exerciseName,
    String? description,
    String? difficultyLevel,
    String? exerciseType,
    String? imageUrl,
    int? caloriesBurnedPerMin,
  }) = _WorkoutExerciseSummary;

  factory WorkoutExerciseSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseSummaryFromJson(json);
}

// ========================= REQUEST MODELS =========================

/// Request to create a new workout plan (POST /workout-plans)
@freezed
class CreateWorkoutPlanRequest with _$CreateWorkoutPlanRequest {
  const factory CreateWorkoutPlanRequest({
    required String planName,
    String? description,
    int? goalId,
    @Default(1) muscleGroupId,
    int? frequencyPerWeek,
    int? durationWeeks,
    String? difficultyLevel,
    String? startDate,
    @Default(true) bool allowWorkoutSwaps,
    @Default([]) List<DateTime> workoutDates
  }) = _CreateWorkoutPlanRequest;

  factory CreateWorkoutPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutPlanRequestFromJson(json);
}

/// Request to add a session to a workout plan (POST /workout-plans/{planId}/sessions)
@freezed
class CreateWorkoutSessionRequest with _$CreateWorkoutSessionRequest {
  const factory CreateWorkoutSessionRequest({
    required String sessionName,
    required int dayNumber,
    String? focusArea,
    int? estimatedDuration,
    String? warmUpNotes,
    String? coolDownNotes,
    @Default(false) bool isRestDay,
    @Default([]) List<CreateSessionExerciseRequest> exercises,
  }) = _CreateWorkoutSessionRequest;

  factory CreateWorkoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutSessionRequestFromJson(json);
}

/// Request to add an exercise to a session (POST /workout-plans/{planId}/sessions/{sessionId}/exercises)
@freezed
class CreateSessionExerciseRequest with _$CreateSessionExerciseRequest {
  const factory CreateSessionExerciseRequest({
    required String exerciseId,
    required int sets,
    required int repetitions,
    double? weightKg,
    int? restTimeSeconds,
    required int orderIndex,
    String? notes,
    @Default(false) bool isSuperset,
  }) = _CreateSessionExerciseRequest;

  factory CreateSessionExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionExerciseRequestFromJson(json);
}

/// Request to generate an AI workout plan (POST /workout-plans/generate)
@freezed
class GenerateAIPlanRequest with _$GenerateAIPlanRequest {
  const factory GenerateAIPlanRequest({
    required List<TargetMuscleGroup> targetMuscleGroups,
    required int durationWeeks,
    required String startDate,
    String? additionalInformation,
  }) = _GenerateAIPlanRequest;

  factory GenerateAIPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateAIPlanRequestFromJson(json);
}

/// Request to update a workout plan (PUT /workout-plans/{planId})
@freezed
class UpdateWorkoutPlanRequest with _$UpdateWorkoutPlanRequest {
  const factory UpdateWorkoutPlanRequest({
    String? planName,
    String? description,
    int? goalId,
    @Default(1) muscleGroupId,
    int? frequencyPerWeek,
    int? durationWeeks,
    String? difficultyLevel,
    bool? allowWorkoutSwaps,
    List<String>? workoutDates,
  }) = _UpdateWorkoutPlanRequest;

  factory UpdateWorkoutPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkoutPlanRequestFromJson(json);
}

/// Request to update a workout session (PUT /workout-plans/{planId}/sessions/{sessionId})
@freezed
class UpdateWorkoutSessionRequest with _$UpdateWorkoutSessionRequest {
  const factory UpdateWorkoutSessionRequest({
    String? sessionName,
    int? dayNumber,
    String? focusArea,
    int? estimatedDuration,
    String? warmUpNotes,
    String? coolDownNotes,
    bool? isRestDay,
  }) = _UpdateWorkoutSessionRequest;

  factory UpdateWorkoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkoutSessionRequestFromJson(json);
}

/// Filter request for workout plans (GET /workout-plans/filter)
@freezed
class WorkoutPlanFilterRequest with _$WorkoutPlanFilterRequest {
  const factory WorkoutPlanFilterRequest({
    bool? isActive,
    String? fitnessGoal,
    @Default(1) muscleGroupId,
    bool? aiGenerated,
    String? startDate,
    String? endDate,
  }) = _WorkoutPlanFilterRequest;

  factory WorkoutPlanFilterRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanFilterRequestFromJson(json);
}

/// Request to update a session exercise (PUT /workout-plans/{planId}/sessions/{sessionId}/exercises/{sessionExerciseId})
@freezed
class UpdateSessionExerciseRequest with _$UpdateSessionExerciseRequest {
  const factory UpdateSessionExerciseRequest({
    String? exerciseId,
    int? sets,
    int? repetitions,
    double? weightKg,
    int? restTimeSeconds,
    int? orderIndex,
    String? notes,
    bool? isSuperset,
  }) = _UpdateSessionExerciseRequest;

  factory UpdateSessionExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSessionExerciseRequestFromJson(json);
}

/// Request to reschedule a workout session (PUT /workout-plans/{planId}/sessions/{sessionId}/reschedule)
@freezed
class RescheduleWorkoutSessionRequest with _$RescheduleWorkoutSessionRequest {
  const factory RescheduleWorkoutSessionRequest({
    required DateTime newDate,
    RescheduleReason? rescheduleReason,
    String? notes,
  }) = _RescheduleWorkoutSessionRequest;

  factory RescheduleWorkoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$RescheduleWorkoutSessionRequestFromJson(json);
}
