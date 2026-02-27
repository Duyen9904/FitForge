import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/exercise_repository.dart';
import 'exercise_types_state.dart';

/// Provider for ExerciseTypesViewModel
final exerciseTypesViewModelProvider =
    StateNotifierProvider<ExerciseTypesViewModel, ExerciseTypesState>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseTypesViewModel(repository: repository);
});

/// ViewModel for managing exercise types / categories state
class ExerciseTypesViewModel extends StateNotifier<ExerciseTypesState> {
  final ExerciseRepository _repository;

  ExerciseTypesViewModel({required ExerciseRepository repository})
      : _repository = repository,
        super(const ExerciseTypesState.initial());

  /// Load all exercise types
  Future<void> loadTypes() async {
    state = const ExerciseTypesState.loading();

    try {
      final types = await _repository.getExerciseTypes();

      state = ExerciseTypesState.loaded(types: types);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load exercise types',
        name: 'ExerciseTypesViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = ExerciseTypesState.error(e.toString());
    }
  }

  /// Select difficulty filter
  void selectDifficulty(String? difficulty) {
    final currentState = state;
    if (currentState is ExerciseTypesLoaded) {
      state = ExerciseTypesLoaded(
        types: currentState.types,
        selectedDifficulty:
            currentState.selectedDifficulty == difficulty ? null : difficulty,
      );
    }
  }

  /// Refresh types
  Future<void> refresh() async {
    await loadTypes();
  }
}
