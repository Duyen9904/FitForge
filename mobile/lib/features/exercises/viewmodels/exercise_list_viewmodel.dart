import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_filter.dart';
import '../repositories/exercise_repository.dart';
import 'exercise_list_state.dart';

/// Provider for ExerciseListViewModel
final exerciseListViewModelProvider =
    StateNotifierProvider<ExerciseListViewModel, ExerciseListState>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseListViewModel(repository: repository);
});

/// ViewModel for managing exercise list state
class ExerciseListViewModel extends StateNotifier<ExerciseListState> {
  final ExerciseRepository _repository;

  ExerciseListViewModel({required ExerciseRepository repository})
      : _repository = repository,
        super(const ExerciseListState.initial());

  /// Load exercises with optional filter
  Future<void> loadExercises({
    ExerciseFilter? filter,
    String? sort,
  }) async {
    state = const ExerciseListState.loading();

    try {
      final pageData = await _repository.browseExercises(
        filter: filter,
        page: 0,
        size: 20,
        sort: sort,
      );

      state = ExerciseListState.loaded(
        exercises: pageData.content,
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        activeFilter: filter ?? const ExerciseFilter(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load exercises',
        name: 'ExerciseListViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = ExerciseListState.error(e.toString());
    }
  }

  /// Load more exercises (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ExerciseListLoaded) return;
    if (!currentState.hasMore) return;

    state = ExerciseListState.loadingMore(
      exercises: currentState.exercises,
      currentPage: currentState.currentPage,
      activeFilter: currentState.activeFilter,
    );

    try {
      final nextPage = currentState.currentPage + 1;
      final pageData = await _repository.browseExercises(
        filter: currentState.activeFilter,
        page: nextPage,
        size: 20,
      );

      // Append new exercises to existing list
      final updatedExercises = [
        ...currentState.exercises,
        ...pageData.content,
      ];

      state = ExerciseListState.loaded(
        exercises: updatedExercises,
        currentPage: pageData.page,
        totalPages: pageData.totalPages,
        hasMore: !pageData.last,
        activeFilter: currentState.activeFilter,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load more exercises',
        name: 'ExerciseListViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Revert to loaded state on error
      state = ExerciseListState.loaded(
        exercises: currentState.exercises,
        currentPage: currentState.currentPage,
        totalPages: (currentState as ExerciseListLoadingMore).currentPage + 1,
        hasMore: true,
        activeFilter: currentState.activeFilter,
      );
    }
  }

  /// Apply filter and reload
  Future<void> applyFilter(ExerciseFilter filter) async {
    await loadExercises(filter: filter);
  }

  /// Clear filter and reload
  Future<void> clearFilter() async {
    await loadExercises(filter: const ExerciseFilter());
  }

  /// Search exercises
  Future<void> search(String query) async {
    final currentState = state;
    final currentFilter = currentState is ExerciseListLoaded
        ? currentState.activeFilter
        : const ExerciseFilter();

    final newFilter = currentFilter.copyWith(searchQuery: query);
    await loadExercises(filter: newFilter);
  }

  /// Refresh exercises (pull-to-refresh)
  Future<void> refresh() async {
    final currentState = state;
    final currentFilter = currentState is ExerciseListLoaded
        ? currentState.activeFilter
        : const ExerciseFilter();

    await loadExercises(filter: currentFilter);
  }

  /// Toggle favorite (optimistic update)
  Future<void> toggleFavorite(int exerciseId, bool currentlyFavorite) async {
    final currentState = state;
    if (currentState is! ExerciseListLoaded) return;

    try {
      if (currentlyFavorite) {
        await _repository.removeFromFavorites(exerciseId);
      } else {
        await _repository.addToFavorites(exerciseId);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to toggle favorite',
        name: 'ExerciseListViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // If API fails, the UI will show error via SnackBar
      rethrow;
    }
  }
}
