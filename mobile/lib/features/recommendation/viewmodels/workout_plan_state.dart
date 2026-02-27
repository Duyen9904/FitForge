import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/recommendation_models.dart';

part 'workout_plan_state.freezed.dart';

/// State for workout plan recommendation
@freezed
class WorkoutPlanState with _$WorkoutPlanState {
  /// Initial state - no plan loaded
  const factory WorkoutPlanState.initial() = WorkoutPlanInitial;

  /// Loading plan from server
  const factory WorkoutPlanState.loading() = WorkoutPlanLoading;

  /// Plan loaded successfully
  const factory WorkoutPlanState.loaded({
    required WorkoutPlanResponse plan,
    WorkoutSessionResponse? currentSession,
    @Default(1) int currentDay,
  }) = WorkoutPlanLoaded;

  /// Generating new plan
  const factory WorkoutPlanState.generating() = WorkoutPlanGenerating;

  /// Adjusting existing plan
  const factory WorkoutPlanState.adjusting({
    required WorkoutPlanResponse currentPlan,
  }) = WorkoutPlanAdjusting;

  /// Loading session for specific day
  const factory WorkoutPlanState.loadingSession({
    required WorkoutPlanResponse plan,
    required int dayNumber,
  }) = WorkoutPlanLoadingSession;

  /// Error state
  const factory WorkoutPlanState.error(String message) = WorkoutPlanError;
}
