import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/workout_plan_models.dart';

part 'workout_plan_detail_state.freezed.dart';

/// Loading state for session exercises
enum SessionLoadingState { idle, loading, loaded, error }

/// State for workout plan detail screen
@freezed
class WorkoutPlanDetailState with _$WorkoutPlanDetailState {
  const factory WorkoutPlanDetailState.initial() = WorkoutPlanDetailInitial;

  const factory WorkoutPlanDetailState.loading() = WorkoutPlanDetailLoading;

  const factory WorkoutPlanDetailState.loaded({
    required WorkoutPlanResponse plan,
    @Default(0) int selectedSessionIndex,
    @Default(SessionLoadingState.idle) SessionLoadingState sessionLoadingState,
    WorkoutSessionResponse? loadedSession,
    String? sessionError,
    @Default(1) int currentWeekNumber,
    @Default(1) int totalWeeks,
    @Default([]) List<WorkoutSessionResponse> weekSessions,
    @Default('') String weekLabel,
  }) = WorkoutPlanDetailLoaded;

  const factory WorkoutPlanDetailState.error(String message) =
      WorkoutPlanDetailError;
}
