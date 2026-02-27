import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/exercise_repository.dart';
import 'exercise_categories_state.dart';

/// Provider for ExerciseCategoriesViewModel
final exerciseCategoriesViewModelProvider =
    StateNotifierProvider<ExerciseCategoriesViewModel, ExerciseCategoriesState>(
        (ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseCategoriesViewModel(repository: repository);
});

/// ViewModel for managing exercise categories state
class ExerciseCategoriesViewModel
    extends StateNotifier<ExerciseCategoriesState> {
  final ExerciseRepository _repository;

  ExerciseCategoriesViewModel({required ExerciseRepository repository})
      : _repository = repository,
        super(const ExerciseCategoriesState.initial());

  /// Load all exercise categories
  Future<void> loadCategories() async {
    state = const ExerciseCategoriesState.loading();

    try {
      final categories = await _repository.getExerciseCategories();
      state = ExerciseCategoriesState.loaded(categories: categories);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load exercise categories',
        name: 'ExerciseCategoriesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = ExerciseCategoriesState.error(e.toString());
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}
