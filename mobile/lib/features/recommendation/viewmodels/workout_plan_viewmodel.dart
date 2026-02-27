import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/recommendation_repository.dart';
import 'workout_plan_state.dart';

/// Provider for WorkoutPlanViewModel
final workoutPlanViewModelProvider =
    StateNotifierProvider<WorkoutPlanViewModel, WorkoutPlanState>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return WorkoutPlanViewModel(repository: repository);
});

/// ViewModel for managing workout plan recommendation state
class WorkoutPlanViewModel extends StateNotifier<WorkoutPlanState> {
  final RecommendationRepository _repository;

  WorkoutPlanViewModel({required RecommendationRepository repository})
      : _repository = repository,
        super(const WorkoutPlanState.initial());

  /// Generate initial workout plan
  Future<void> generatePlan(String startDate) async {
    state = const WorkoutPlanState.generating();

    try {
      final plan = await _repository.generateWorkoutPlan(startDate);
      state = WorkoutPlanState.loaded(plan: plan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate workout plan',
        name: 'WorkoutPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutPlanState.error(e.toString());
    }
  }

  /// Adjust workout plan based on behavior
  Future<void> adjustPlan(int planId) async {
    final currentState = state;
    if (currentState is! WorkoutPlanLoaded) return;

    state = WorkoutPlanState.adjusting(currentPlan: currentState.plan);

    try {
      final adjustedPlan = await _repository.adjustWorkoutPlan(planId);
      state = WorkoutPlanState.loaded(plan: adjustedPlan);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to regenerate workout session',
        name: 'WorkoutPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Restore previous state on error
      state = WorkoutPlanState.loaded(plan: currentState.plan);
      rethrow;
    }
  }

  /// Load workout session for specific day
  Future<void> loadSessionForDay(int planId, int dayNumber) async {
    final currentState = state;
    if (currentState is! WorkoutPlanLoaded) return;

    state = WorkoutPlanState.loadingSession(
      plan: currentState.plan,
      dayNumber: dayNumber,
    );

    try {
      final session = await _repository.getWorkoutSessionForDay(planId, dayNumber);
      state = WorkoutPlanState.loaded(
        plan: currentState.plan,
        currentSession: session,
        currentDay: dayNumber,
      );
    } catch (e) {
      state = WorkoutPlanState.loaded(
        plan: currentState.plan,
        currentDay: dayNumber,
      );
      rethrow;
    }
  }
  /// Reset to initial state
  void reset() {
    state = const WorkoutPlanState.initial();
  }
}
