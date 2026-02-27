import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_plan_models.dart';
import '../repositories/workout_plan_repository.dart';
import 'workout_plans_state.dart';

/// Provider for WorkoutPlansViewModel
final workoutPlansViewModelProvider =
    StateNotifierProvider<WorkoutPlansViewModel, WorkoutPlansState>((ref) {
  final repository = ref.watch(workoutPlanRepositoryProvider);
  return WorkoutPlansViewModel(repository: repository);
});

/// ViewModel for managing workout plans list state
class WorkoutPlansViewModel extends StateNotifier<WorkoutPlansState> {
  final WorkoutPlanRepository _repository;

  WorkoutPlansViewModel({required WorkoutPlanRepository repository})
      : _repository = repository,
        super(const WorkoutPlansState.initial());

  /// Load workout plans (initial load)
  Future<void> loadPlans() async {
    state = const WorkoutPlansState.loading();

    try {
      final currentState = state;
      final filter = currentState is WorkoutPlansLoaded 
          ? currentState.appliedFilter 
          : null;

      final pageData = filter != null
          ? await _repository.filterPlans(filter: filter, page: 0)
          : await _repository.getUserPlans(page: 0);

      state = WorkoutPlansState.loaded(
        plans: pageData.content,
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        appliedFilter: filter,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load workout plans',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutPlansState.error(e.toString());
    }
  }

  /// Load more plans (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! WorkoutPlansLoaded || !currentState.hasMore) return;

    try {
      final nextPage = currentState.currentPage + 1;
      final filter = currentState.appliedFilter;

      final pageData = filter != null
          ? await _repository.filterPlans(filter: filter, page: nextPage)
          : await _repository.getUserPlans(page: nextPage);

      state = WorkoutPlansLoaded(
        plans: [...currentState.plans, ...pageData.content],
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        selectedDifficulty: currentState.selectedDifficulty,
        appliedFilter: currentState.appliedFilter,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load more workout plans',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Keep current state on load-more failure
    }
  }

  /// Select difficulty filter (client-side filtering)
  void selectDifficulty(String? difficulty) {
    final currentState = state;
    if (currentState is WorkoutPlansLoaded) {
      state = WorkoutPlansLoaded(
        plans: currentState.plans,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        hasMore: currentState.hasMore,
        selectedDifficulty:
            currentState.selectedDifficulty == difficulty ? null : difficulty,
        appliedFilter: currentState.appliedFilter,
      );
    }
  }

  /// Refresh plans (pull to refresh)
  Future<void> refresh() async {
    await loadPlans();
  }

  /// Duplicate a workout plan
  Future<void> duplicatePlan(int planId, String newName) async {
    try {
      await _repository.duplicatePlan(planId, newPlanName: newName);
      // Refresh the list to include the new plan
      await refresh();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to duplicate workout plan',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a workout plan
  Future<void> deletePlan(int planId) async {
    final currentState = state;
    if (currentState is! WorkoutPlansLoaded) return;

    try {
      // Optimistically remove from list
      final updatedPlans = currentState.plans
          .where((plan) => plan.planId != planId)
          .toList();

      state = WorkoutPlansLoaded(
        plans: updatedPlans,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        hasMore: currentState.hasMore,
        selectedDifficulty: currentState.selectedDifficulty,
        appliedFilter: currentState.appliedFilter,
      );

      await _repository.deletePlan(planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete workout plan',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Rollback on error
      await refresh();
      rethrow;
    }
  }

  /// Toggle active status of a workout plan
  Future<void> togglePlanActive(int planId) async {
    final currentState = state;
    if (currentState is! WorkoutPlansLoaded) return;

    try {
      // Optimistically update in list
      final updatedPlans = currentState.plans.map((plan) {
        if (plan.planId == planId) {
          return plan.copyWith(isActive: !plan.isActive);
        }
        return plan;
      }).toList();

      state = WorkoutPlansLoaded(
        plans: updatedPlans,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        hasMore: currentState.hasMore,
        selectedDifficulty: currentState.selectedDifficulty,
        appliedFilter: currentState.appliedFilter,
      );

      await _repository.togglePlanActive(planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to toggle workout plan active status',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Rollback on error
      await refresh();
      rethrow;
    }
  }

  /// Apply filters to workout plans
  Future<void> applyFilters(WorkoutPlanFilterRequest filter) async {
    state = const WorkoutPlansState.loading();

    try {
      final pageData = await _repository.filterPlans(filter: filter, page: 0);

      state = WorkoutPlansState.loaded(
        plans: pageData.content,
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        appliedFilter: filter,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to filter workout plans',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutPlansState.error(e.toString());
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    state = const WorkoutPlansState.loading();

    try {
      final pageData = await _repository.getUserPlans(page: 0);

      state = WorkoutPlansState.loaded(
        plans: pageData.content,
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        appliedFilter: null,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to clear filters',
        name: 'WorkoutPlansViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutPlansState.error(e.toString());
    }
  }
}
