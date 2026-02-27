import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_models.dart';
import '../repositories/exercise_repository.dart';
import 'exercise_detail_state.dart';

/// Provider factory for ExerciseDetailViewModel
/// Each exercise detail screen gets its own instance
final exerciseDetailViewModelProvider = StateNotifierProvider.family<
    ExerciseDetailViewModel, ExerciseDetailState, int>((ref, exerciseId) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseDetailViewModel(
    repository: repository,
    exerciseId: exerciseId,
  );
});

/// ViewModel for managing exercise detail state
class ExerciseDetailViewModel extends StateNotifier<ExerciseDetailState> {
  final ExerciseRepository _repository;
  final int exerciseId;

  ExerciseDetailViewModel({
    required ExerciseRepository repository,
    required this.exerciseId,
  })  : _repository = repository,
        super(const ExerciseDetailState.initial()) {
    loadExercise();
  }

  /// Load exercise details
  Future<void> loadExercise() async {
    state = const ExerciseDetailState.loading();

    try {
      // Load exercise details and favorite status in parallel
      final results = await Future.wait<Object>([
        _repository.getExerciseById(exerciseId),
        _repository.isFavorite(exerciseId),
      ]);

      final exercise = results[0] as Exercise;
      final isFavorite = results[1] as bool;

      state = ExerciseDetailState.loaded(
        exercise: exercise,
        isFavorite: isFavorite,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load exercise details',
        name: 'ExerciseDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = ExerciseDetailState.error(e.toString());
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    final currentState = state;
    if (currentState is! ExerciseDetailLoaded) return;

    // Optimistic update - show loading state
    state = currentState.copyWith(isTogglingFavorite: true);

    try {
      if (currentState.isFavorite) {
        await _repository.removeFromFavorites(exerciseId);
      } else {
        await _repository.addToFavorites(exerciseId);
      }

      // Update state with new favorite status
      state = currentState.copyWith(
        isFavorite: !currentState.isFavorite,
        isTogglingFavorite: false,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to toggle favorite',
        name: 'ExerciseDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Revert to previous state on error
      state = currentState.copyWith(isTogglingFavorite: false);
      rethrow; // Let UI show error message
    }
  }

  /// Refresh exercise details
  Future<void> refresh() async {
    await loadExercise();
  }
}
