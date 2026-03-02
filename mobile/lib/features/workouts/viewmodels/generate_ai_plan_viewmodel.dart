import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/target_muscle_group.dart';
import '../models/workout_plan_models.dart';
import '../repositories/workout_plan_repository.dart';
import 'generate_ai_plan_state.dart';

/// Provider for GenerateAIPlanViewModel
final generateAIPlanViewModelProvider = StateNotifierProvider.autoDispose<
    GenerateAIPlanViewModel, GenerateAIPlanState>((ref) {
  final repository = ref.watch(workoutPlanRepositoryProvider);
  return GenerateAIPlanViewModel(repository: repository);
});

/// ViewModel for the AI workout plan generation screen
class GenerateAIPlanViewModel extends StateNotifier<GenerateAIPlanState> {
  final WorkoutPlanRepository _repository;

  GenerateAIPlanViewModel({required WorkoutPlanRepository repository})
      : _repository = repository,
        super(GenerateAIPlanState.editing(startDate: DateTime.now()));

  // ======================== FORM UPDATES ========================

  void toggleMuscleGroup(TargetMuscleGroup group) {
    final current = state;
    if (current is! GenerateAIPlanEditing) return;

    final updated = Set<TargetMuscleGroup>.from(current.selectedMuscleGroups);
    if (updated.contains(group)) {
      updated.remove(group);
    } else {
      updated.add(group);
    }
    state = current.copyWith(selectedMuscleGroups: updated);
  }

  void updateDurationWeeks(int weeks) {
    _updateEditing((s) => s.copyWith(durationWeeks: weeks));
  }

  void updateStartDate(DateTime? date) {
    _updateEditing((s) => s.copyWith(startDate: date));
  }

  void updateAdditionalInfo(String text) {
    _updateEditing((s) => s.copyWith(additionalInfo: text));
  }

  // ======================== VALIDATION ========================

  bool get isFormValid {
    final current = state;
    if (current is! GenerateAIPlanEditing) return false;
    return current.selectedMuscleGroups.isNotEmpty &&
        current.durationWeeks >= 1 &&
        current.durationWeeks <= 52 &&
        current.startDate != null;
  }

  // ======================== SUBMIT ========================

  Future<void> submit() async {
    final current = state;
    if (current is! GenerateAIPlanEditing) return;
    if (!isFormValid) return;

    state = const GenerateAIPlanState.submitting();

    try {
      final startDate = current.startDate!;
      final startDateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

      final request = GenerateAIPlanRequest(
        targetMuscleGroups: current.selectedMuscleGroups.toList(),
        durationWeeks: current.durationWeeks,
        startDate: startDateStr,
        additionalInformation: current.additionalInfo.trim().isNotEmpty
            ? current.additionalInfo.trim()
            : null,
      );

      final response = await _repository.generateAIPlan(request);
      state = GenerateAIPlanState.success(planId: response.planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate AI workout plan',
        name: 'GenerateAIPlanViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = GenerateAIPlanState.error(message: e.toString());
    }
  }

  /// Return to editing state (e.g., after error)
  void retryFromError() {
    state = GenerateAIPlanState.editing(startDate: DateTime.now());
  }

  // ======================== HELPERS ========================

  void _updateEditing(
      GenerateAIPlanEditing Function(GenerateAIPlanEditing) updater) {
    final current = state;
    if (current is GenerateAIPlanEditing) {
      state = updater(current);
    }
  }
}
