import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/workout_plan_models.dart';

part 'workout_plans_state.freezed.dart';

/// State for workout plans list screen
@freezed
class WorkoutPlansState with _$WorkoutPlansState {
  const factory WorkoutPlansState.initial() = WorkoutPlansInitial;

  const factory WorkoutPlansState.loading() = WorkoutPlansLoading;

  const factory WorkoutPlansState.loaded({
    required List<WorkoutPlanSummaryResponse> plans,
    @Default(0) int currentPage,
    @Default(0) int totalPages,
    @Default(true) bool hasMore,
    String? selectedDifficulty,
    WorkoutPlanFilterRequest? appliedFilter,
  }) = WorkoutPlansLoaded;

  const factory WorkoutPlansState.error(String message) = WorkoutPlansError;
}
