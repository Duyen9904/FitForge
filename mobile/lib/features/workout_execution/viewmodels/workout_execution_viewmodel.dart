import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workouts/models/workout_plan_models.dart';
import '../models/workout_execution_models.dart';
import '../repositories/workout_execution_repository.dart';
import 'workout_execution_state.dart';

/// Provider for WorkoutExecutionViewModel
final workoutExecutionViewModelProvider = StateNotifierProvider<
    WorkoutExecutionViewModel, WorkoutExecutionState>((ref) {
  final repository = ref.watch(workoutExecutionRepositoryProvider);
  return WorkoutExecutionViewModel(repository: repository);
});

/// ViewModel managing the full workout execution lifecycle.
///
/// Flow: startWorkout → logCurrentSet (per set) → goToRest → goToNextExercise → ... → completeWorkout
class WorkoutExecutionViewModel
    extends StateNotifier<WorkoutExecutionState> {
  final WorkoutExecutionRepository _repository;

  WorkoutExecutionViewModel({required WorkoutExecutionRepository repository})
      : _repository = repository,
        super(const WorkoutExecutionState.initial());

  // Cached data used across state transitions
  List<SessionExerciseResponse> _exercises = [];
  int _progressId = 0;

  /// UC-5.1: Start a workout session.
  /// Called after the "Get Ready" countdown completes.
  Future<void> startWorkout(
      int sessionId, List<SessionExerciseResponse> exercises) async {
    state = const WorkoutExecutionState.starting();
    _exercises = List.from(exercises)
      ..sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

    try {
      // Auto-cancel any stale in-progress workout
      try {
        final currentWorkout = await _repository.getCurrentWorkout();
        if (currentWorkout != null &&
            currentWorkout.progressId != null &&
            currentWorkout.progressId! > 0 &&
            !currentWorkout.completed) {
          developer.log(
            'Found stale workout ${currentWorkout.progressId}, cancelling...',
            name: 'WorkoutExecutionViewModel',
          );
          await _repository.cancelWorkout(currentWorkout.progressId!);
        }
      } catch (_) {
        // No current workout or failed to fetch — proceed normally
      }

      final request = StartWorkoutRequest(sessionId: sessionId);
      final progress = await _repository.startWorkout(request);
      _progressId = progress.progressId ?? 0;

      if (_exercises.isEmpty) {
        state = WorkoutExecutionState.error('No exercises in this session');
        return;
      }

      final firstExercise = _exercises[0];
      state = WorkoutExecutionState.exerciseInProgress(
        progressId: _progressId,
        exercises: _exercises,
        currentExerciseIndex: 0,
        currentSetNumber: 1,
        totalSets: firstExercise.sets ?? 3,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to start workout',
        name: 'WorkoutExecutionViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutExecutionState.error(e.toString());
    }
  }

  /// UC-5.2: Log the current set as completed.
  /// Advances to next set, or to rest if all sets done.
  Future<void> logCurrentSet() async {
    final currentState = state;
    if (currentState is! WorkoutExerciseInProgress) return;

    final exercise = _exercises[currentState.currentExerciseIndex];

    try {
      final request = LogExerciseRequest(
        exerciseId: exercise.exercise?.exerciseId ?? '',
        setNumber: currentState.currentSetNumber,
        repetitionsCompleted: exercise.repetitions,
        weightUsedKg: exercise.weightKg,
        restTimeSeconds: exercise.restTimeSeconds,
        completed: true,
      );

      await _repository.logExercise(_progressId, request);

      // Check if more sets remain
      if (currentState.currentSetNumber < currentState.totalSets) {
        // Rest between sets
        _goToRestBetweenSets(
          currentState.currentExerciseIndex,
          currentState.currentSetNumber + 1,
          currentState.totalSets,
        );
      } else {
        // All sets done — go to rest (or finish if last exercise)
        goToRest();
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to log exercise set',
        name: 'WorkoutExecutionViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutExecutionState.error(e.toString());
    }
  }

  /// UC-5.4: Skip the current exercise.
  Future<void> skipExercise({String reason = 'TOO_DIFFICULT'}) async {
    final currentState = state;
    if (currentState is! WorkoutExerciseInProgress) return;

    final exercise = _exercises[currentState.currentExerciseIndex];

    try {
      final request = SkipExerciseRequest(
        exerciseId: exercise.exercise?.exerciseId ?? '',
        reason: reason,
      );

      await _repository.skipExercise(_progressId, request);

      // Move to rest or complete
      goToRest();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to skip exercise',
        name: 'WorkoutExecutionViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutExecutionState.error(e.toString());
    }
  }

  /// Transition to rest state between exercises.
  void goToRest() {
    final currentState = state;
    int currentIndex = 0;

    if (currentState is WorkoutExerciseInProgress) {
      currentIndex = currentState.currentExerciseIndex;
    }

    // If this was the last exercise, go to completing
    if (currentIndex >= _exercises.length - 1) {
      _autoComplete();
      return;
    }

    final currentExercise = _exercises[currentIndex];
    final totalSets = currentExercise.sets ?? 3;
    state = WorkoutExecutionState.resting(
      progressId: _progressId,
      exercises: _exercises,
      currentExerciseIndex: currentIndex,
      restTimeSeconds: currentExercise.restTimeSeconds ?? 30,
      nextSetNumber: totalSets + 1, // signals "done with all sets"
      totalSets: totalSets,
    );
  }

  /// Rest between sets of the same exercise.
  void _goToRestBetweenSets(int exerciseIndex, int nextSet, int totalSets) {
    final exercise = _exercises[exerciseIndex];
    state = WorkoutExecutionState.resting(
      progressId: _progressId,
      exercises: _exercises,
      currentExerciseIndex: exerciseIndex,
      restTimeSeconds: exercise.restTimeSeconds ?? 30,
      nextSetNumber: nextSet,
      totalSets: totalSets,
    );
  }

  /// Resume the same exercise at the next set after between-set rest.
  void goToNextSet(int exerciseIndex, int setNumber, int totalSets) {
    state = WorkoutExecutionState.exerciseInProgress(
      progressId: _progressId,
      exercises: _exercises,
      currentExerciseIndex: exerciseIndex,
      currentSetNumber: setNumber,
      totalSets: totalSets,
    );
  }

  /// Transition to the next exercise after rest.
  void goToNextExercise() {
    final currentState = state;
    int nextIndex = 0;

    if (currentState is WorkoutExerciseResting) {
      nextIndex = currentState.currentExerciseIndex + 1;
    }

    if (nextIndex >= _exercises.length) {
      _autoComplete();
      return;
    }

    final nextExercise = _exercises[nextIndex];
    state = WorkoutExecutionState.exerciseInProgress(
      progressId: _progressId,
      exercises: _exercises,
      currentExerciseIndex: nextIndex,
      currentSetNumber: 1,
      totalSets: nextExercise.sets ?? 3,
    );
  }

  /// Go to the previous exercise (if possible).
  void goToPreviousExercise() {
    final currentState = state;
    if (currentState is! WorkoutExerciseInProgress) return;

    final prevIndex = currentState.currentExerciseIndex - 1;
    if (prevIndex < 0) return;

    final prevExercise = _exercises[prevIndex];
    state = WorkoutExecutionState.exerciseInProgress(
      progressId: _progressId,
      exercises: _exercises,
      currentExerciseIndex: prevIndex,
      currentSetNumber: 1,
      totalSets: prevExercise.sets ?? 3,
    );
  }

  /// UC-5.3: Complete the workout.
  Future<void> completeWorkout({
    int difficultyRating = 3,
    String? performanceNotes,
    String? moodRating,
  }) async {
    state = WorkoutExecutionState.completing(progressId: _progressId);

    try {
      final request = CompleteWorkoutRequest(
        difficultyRating: difficultyRating,
        performanceNotes: performanceNotes,
        moodRating: moodRating,
      );

      final result = await _repository.completeWorkout(_progressId, request);

      state = WorkoutExecutionState.completed(
        result: result,
        totalExercises: _exercises.length,
        totalCalories: result.caloriesBurned ?? 0,
        totalMinutes: result.durationMinutes ?? 0,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to complete workout',
        name: 'WorkoutExecutionViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutExecutionState.error(e.toString());
    }
  }

  /// Cancel/stop the workout.
  Future<void> cancelWorkout() async {
    if (_progressId > 0) {
      try {
        await _repository.cancelWorkout(_progressId);
      } catch (e) {
        developer.log(
          'Failed to cancel workout',
          name: 'WorkoutExecutionViewModel',
          error: e,
        );
      }
    }
    state = const WorkoutExecutionState.initial();
  }

  /// Reset viewmodel state without calling any API.
  /// Use after a workout is already completed (e.g. from congrats screen).
  void resetState() {
    _progressId = 0;
    _exercises = [];
    state = const WorkoutExecutionState.initial();
  }

  /// Auto-complete after the last exercise.
  void _autoComplete() {
    state = WorkoutExecutionState.completing(progressId: _progressId);
  }

  // ===== Getters for the current state =====

  /// Get the current exercise being performed (or null).
  SessionExerciseResponse? get currentExercise {
    final s = state;
    if (s is WorkoutExerciseInProgress &&
        s.currentExerciseIndex < _exercises.length) {
      return _exercises[s.currentExerciseIndex];
    }
    return null;
  }

  /// Get the next exercise name (for rest screen).
  String get nextExerciseName {
    final s = state;
    int nextIndex = 0;
    if (s is WorkoutExerciseResting) {
      nextIndex = s.currentExerciseIndex + 1;
    }
    if (nextIndex < _exercises.length) {
      return _exercises[nextIndex].exercise?.exerciseName ?? 'Next Exercise';
    }
    return 'Done!';
  }

  /// Whether this is the last exercise.
  bool get isLastExercise {
    final s = state;
    if (s is WorkoutExerciseInProgress) {
      return s.currentExerciseIndex >= _exercises.length - 1;
    }
    if (s is WorkoutExerciseResting) {
      return s.currentExerciseIndex >= _exercises.length - 1;
    }
    return false;
  }

  int get progressId => _progressId;
  List<SessionExerciseResponse> get exercises => _exercises;
}
