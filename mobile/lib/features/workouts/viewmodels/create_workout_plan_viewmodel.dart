import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exercises/models/exercise_models.dart';
import '../models/workout_plan_models.dart';
import '../repositories/workout_plan_repository.dart';
import '../services/workout_plan_service.dart';
import 'create_workout_plan_state.dart';

/// Provider for CreateWorkoutPlanViewModel
final createWorkoutPlanViewModelProvider = StateNotifierProvider.autoDispose<
    CreateWorkoutPlanViewModel, CreateWorkoutPlanState>((ref) {
  final repository = ref.watch(workoutPlanRepositoryProvider);
  return CreateWorkoutPlanViewModel(repository: repository);
});

/// Active viewmodel provider — used by step widgets
final activeWorkoutPlanViewModelProvider = StateNotifierProvider.autoDispose<
    CreateWorkoutPlanViewModel, CreateWorkoutPlanState>((ref) {
  final repository = ref.watch(workoutPlanRepositoryProvider);
  return CreateWorkoutPlanViewModel(repository: repository);
});

/// FutureProvider for fetching all goals from the API
final goalsProvider = FutureProvider.autoDispose<List<GoalResponse>>((ref) async {
  final service = ref.watch(workoutPlanServiceProvider);
  final response = await service.getAllGoals();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to fetch goals');
  }
  return response.data!;
});

/// FutureProvider for fetching all muscle groups from the API
final muscleGroupsProvider = FutureProvider.autoDispose<List<MuscleGroup>>((ref) async {
  final service = ref.watch(workoutPlanServiceProvider);
  final response = await service.getAllMuscleGroups();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to fetch muscle groups');
  }
  return response.data!;
});

/// ViewModel for the multi-step workout plan creation wizard
class CreateWorkoutPlanViewModel
    extends StateNotifier<CreateWorkoutPlanState> {
  final WorkoutPlanRepository _repository;

  CreateWorkoutPlanViewModel({
    required WorkoutPlanRepository repository,
  })  : _repository = repository,
        super(CreateWorkoutPlanState.editing(startDate: DateTime.now()));

  // ======================== STEP NAVIGATION ========================

  void goToStep(int step) {
    final current = state;
    if (current is CreateWorkoutPlanEditing) {
      state = current.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    final current = state;
    if (current is CreateWorkoutPlanEditing && current.currentStep < 2) {
      // When going from step 0→1, auto-generate session drafts
      if (current.currentStep == 0 && current.sessions.isEmpty) {
        _generateSessionDrafts(current);
        return;
      }
      state = current.copyWith(currentStep: current.currentStep + 1);
    }
  }

  void previousStep() {
    final current = state;
    if (current is CreateWorkoutPlanEditing && current.currentStep > 0) {
      state = current.copyWith(currentStep: current.currentStep - 1);
    }
  }

  // ======================== STEP 1 – PLAN INFO ========================

  void updatePlanName(String name) {
    _updateEditing((s) => s.copyWith(planName: name));
  }

  void updateDescription(String desc) {
    _updateEditing((s) => s.copyWith(description: desc));
  }

  void updateGoalId(int? goalId) {
    _updateEditing((s) => s.copyWith(goalId: goalId));
  }

  void updateMuscleGroupId(int? id) {
    _updateEditing((s) => s.copyWith(muscleGroupId: id));
  }

  void updateDifficultyLevel(String level) {
    _updateEditing((s) => s.copyWith(difficultyLevel: level));
  }

  void updateFrequencyPerWeek(int freq) {
    _updateEditing((s) => s.copyWith(frequencyPerWeek: freq));
  }

  void updateDurationWeeks(int weeks) {
    _updateEditing((s) => s.copyWith(durationWeeks: weeks));
  }

  void updateStartDate(DateTime? date) {
    _updateEditing((s) => s.copyWith(startDate: date));
  }

  // ======================== STEP 2 – SESSIONS ========================

  // Prefilled session templates for easy testing
  static const _sessionTemplates = [
    {'name': 'Chest & Triceps', 'focus': 'Chest', 'duration': 45},
    {'name': 'Back & Biceps', 'focus': 'Back', 'duration': 50},
    {'name': 'Legs & Shoulders', 'focus': 'Legs', 'duration': 55},
    {'name': 'Upper Body', 'focus': 'Chest', 'duration': 40},
    {'name': 'Lower Body', 'focus': 'Legs', 'duration': 50},
    {'name': 'Full Body', 'focus': 'Back', 'duration': 60},
    {'name': 'Active Recovery', 'focus': 'Core', 'duration': 30},
  ];

  // Sample exercises for each focus area (exerciseId, name)
  static const _sampleExercises = {
    'Chest': [
      {'id': 1, 'name': 'Bench Press'},
      {'id': 2, 'name': 'Incline Dumbbell Press'},
    ],
    'Back': [
      {'id': 3, 'name': 'Barbell Row'},
      {'id': 4, 'name': 'Lat Pulldown'},
    ],
    'Legs': [
      {'id': 5, 'name': 'Barbell Squat'},
      {'id': 6, 'name': 'Romanian Deadlift'},
    ],
    'Core': [
      {'id': 7, 'name': 'Plank'},
      {'id': 8, 'name': 'Russian Twist'},
    ],
  };

  /// Generate 7 session drafts (one per weekday).
  /// The first [frequencyPerWeek] days get workout templates;
  /// the remaining days are marked as rest days.
  /// Each session gets a scheduledDate based on the plan's startDate.
  void _generateSessionDrafts(CreateWorkoutPlanEditing current) {
    final startDate = current.startDate ?? DateTime.now();
    final freq = current.frequencyPerWeek;
    int workoutIndex = 0;

    final sessions = List.generate(7, (i) {
      final date = startDate.add(Duration(days: i));
      final isRest = i >= freq;

      if (isRest) {
        return SessionDraft(
          sessionName: 'Rest Day',
          dayNumber: i + 1,
          scheduledDate: date,
          isRestDay: true,
        );
      }

      final template = _sessionTemplates[workoutIndex % _sessionTemplates.length];
      final focusArea = template['focus'] as String;
      final exercises = (_sampleExercises[focusArea] ?? _sampleExercises['Chest']!)
          .map((e) => ExerciseDraft(
                exerciseId: e['id'] as int,
                exerciseName: e['name'] as String,
                sets: 3,
                repetitions: 10,
                weightKg: 20.0,
                restTimeSeconds: 60,
              ))
          .toList();

      workoutIndex++;
      return SessionDraft(
        sessionName: template['name'] as String,
        dayNumber: i + 1,
        scheduledDate: date,
        focusArea: focusArea,
        estimatedDuration: template['duration'] as int,
        exercises: exercises,
      );
    });

    state = current.copyWith(
      currentStep: 1,
      sessions: sessions,
    );
  }

  void updateSessionName(int index, String name) {
    _updateSession(index, (s) => s.sessionName = name);
  }

  void updateSessionFocusArea(int index, String? focusArea) {
    _updateSession(index, (s) => s.focusArea = focusArea);
  }

  void updateSessionDuration(int index, int? duration) {
    _updateSession(index, (s) => s.estimatedDuration = duration);
  }

  void toggleRestDay(int index) {
    _updateSession(index, (s) {
      s.isRestDay = !s.isRestDay;
      if (s.isRestDay) {
        s.sessionName = 'Rest Day';
        s.focusArea = null;
        s.estimatedDuration = null;
        s.exercises.clear();
      } else {
        s.sessionName = '';
      }
    });
  }

  void updateSessionDate(int index, DateTime? date) {
    _updateSession(index, (s) => s.scheduledDate = date);
  }

  // ======================== STEP 3 – EXERCISES ========================

  void addExercise(int sessionIndex, ExerciseDraft exercise) {
    _updateSession(sessionIndex, (s) {
      s.exercises.add(exercise);
    });
  }

  void removeExercise(int sessionIndex, int exerciseIndex) {
    _updateSession(sessionIndex, (s) {
      if (exerciseIndex < s.exercises.length) {
        s.exercises.removeAt(exerciseIndex);
      }
    });
  }

  void updateExerciseSets(int sessionIndex, int exerciseIndex, int sets) {
    _updateExercise(sessionIndex, exerciseIndex, (e) => e.sets = sets);
  }

  void updateExerciseReps(int sessionIndex, int exerciseIndex, int reps) {
    _updateExercise(sessionIndex, exerciseIndex, (e) => e.repetitions = reps);
  }

  void updateExerciseWeight(
      int sessionIndex, int exerciseIndex, double? weight) {
    _updateExercise(sessionIndex, exerciseIndex, (e) => e.weightKg = weight);
  }

  void updateExerciseRest(int sessionIndex, int exerciseIndex, int? rest) {
    _updateExercise(
        sessionIndex, exerciseIndex, (e) => e.restTimeSeconds = rest);
  }

  // ======================== SUBMIT ========================

  Future<void> submitAll() async {
    final current = state;
    if (current is! CreateWorkoutPlanEditing) return;

    state = const CreateWorkoutPlanState.submitting(
      message: 'Creating workout plan...',
    );

    try {
      final startDateStr = current.startDate != null
          ? '${current.startDate!.year}-${current.startDate!.month.toString().padLeft(2, '0')}-${current.startDate!.day.toString().padLeft(2, '0')}'
          : null;

      final planRequest = CreateWorkoutPlanRequest(
        planName: current.planName,
        description:
            current.description.isNotEmpty ? current.description : null,
        goalId: current.goalId,
        muscleGroupId: current.muscleGroupId,
        frequencyPerWeek: current.frequencyPerWeek,
        durationWeeks: current.durationWeeks,
        difficultyLevel: current.difficultyLevel,
        startDate: startDateStr,
      );

      final planResponse = await _repository.createPlan(planRequest);
      final planId = planResponse.planId;

      // Add sessions
      for (final session in current.sessions) {
        state = CreateWorkoutPlanState.submitting(
          message: 'Adding session: ${session.sessionName}...',
        );

        final exerciseRequests = session.exercises
            .asMap()
            .entries
            .map((entry) => CreateSessionExerciseRequest(
                  exerciseId: entry.value.exerciseId,
                  sets: entry.value.sets,
                  repetitions: entry.value.repetitions,
                  weightKg: entry.value.weightKg,
                  restTimeSeconds: entry.value.restTimeSeconds,
                  orderIndex: entry.key,
                  notes: entry.value.notes,
                ))
            .toList();

        final sessionRequest = CreateWorkoutSessionRequest(
          sessionName: session.sessionName,
          dayNumber: session.dayNumber,
          focusArea: session.focusArea,
          estimatedDuration: session.estimatedDuration,
          isRestDay: session.isRestDay,
          exercises: exerciseRequests,
        );

        await _repository.addSession(planId, sessionRequest);
      }

      state = CreateWorkoutPlanState.success(planId: planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create workout plan',
        name: 'CreateWorkoutPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = CreateWorkoutPlanState.error(message: e.toString());
    }
  }

  /// Reset to editing state (e.g., after error)
  void retryFromError() {
    state = const CreateWorkoutPlanState.editing();
  }

  // ======================== HELPERS ========================

  void _updateEditing(
      CreateWorkoutPlanEditing Function(CreateWorkoutPlanEditing) updater) {
    final current = state;
    if (current is CreateWorkoutPlanEditing) {
      state = updater(current);
    }
  }

  void _updateSession(int index, void Function(SessionDraft) updater) {
    final current = state;
    if (current is CreateWorkoutPlanEditing &&
        index < current.sessions.length) {
      updater(current.sessions[index]);
      // trigger state update
      state = current.copyWith(sessions: List.from(current.sessions));
    }
  }

  void _updateExercise(
      int sessionIndex, int exerciseIndex, void Function(ExerciseDraft) updater) {
    final current = state;
    if (current is CreateWorkoutPlanEditing &&
        sessionIndex < current.sessions.length &&
        exerciseIndex < current.sessions[sessionIndex].exercises.length) {
      updater(current.sessions[sessionIndex].exercises[exerciseIndex]);
      state = current.copyWith(sessions: List.from(current.sessions));
    }
  }

  /// Validate step 1 fields
  bool isStep1Valid() {
    final current = state;
    if (current is! CreateWorkoutPlanEditing) return false;
    return current.planName.trim().isNotEmpty &&
        current.goalId != null &&
        current.muscleGroupId != null &&
        current.startDate != null;
  }

  /// Validate step 2 fields
  bool isStep2Valid() {
    final current = state;
    if (current is! CreateWorkoutPlanEditing) return false;
    return current.sessions.isNotEmpty &&
        current.sessions.every((s) => s.sessionName.trim().isNotEmpty);
  }
}
