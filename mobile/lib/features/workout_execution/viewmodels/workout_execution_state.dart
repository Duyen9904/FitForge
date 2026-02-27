import 'package:freezed_annotation/freezed_annotation.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../models/workout_execution_models.dart';

part 'workout_execution_state.freezed.dart';

/// State for the workout execution flow.
@freezed
class WorkoutExecutionState with _$WorkoutExecutionState {
  /// No workout started yet.
  const factory WorkoutExecutionState.initial() = WorkoutExecutionInitial;

  /// Starting the workout — POST /start in progress.
  const factory WorkoutExecutionState.starting() = WorkoutExecutionStarting;

  /// An exercise is being performed.
  const factory WorkoutExecutionState.exerciseInProgress({
    required int progressId,
    required List<SessionExerciseResponse> exercises,
    required int currentExerciseIndex,
    required int currentSetNumber,
    required int totalSets,
  }) = WorkoutExerciseInProgress;

  /// Resting between exercises.
  const factory WorkoutExecutionState.resting({
    required int progressId,
    required List<SessionExerciseResponse> exercises,
    required int currentExerciseIndex,
    required int restTimeSeconds,
  }) = WorkoutExerciseResting;

  /// Completing the workout — POST /complete in progress.
  const factory WorkoutExecutionState.completing({
    required int progressId,
  }) = WorkoutExecutionCompleting;

  /// Workout completed — show stats.
  const factory WorkoutExecutionState.completed({
    required WorkoutProgressResponse result,
    required int totalExercises,
    required int totalCalories,
    required int totalMinutes,
  }) = WorkoutExecutionCompleted;

  /// An error occurred.
  const factory WorkoutExecutionState.error(String message) =
      WorkoutExecutionError;
}
