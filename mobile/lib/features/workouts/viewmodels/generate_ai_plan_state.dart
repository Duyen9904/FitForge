import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums/target_muscle_group.dart';

part 'generate_ai_plan_state.freezed.dart';

/// State for the AI workout plan generation screen
@freezed
class GenerateAIPlanState with _$GenerateAIPlanState {
  /// User is filling in the form
  const factory GenerateAIPlanState.editing({
    @Default({}) Set<TargetMuscleGroup> selectedMuscleGroups,
    @Default(4) int durationWeeks,
    @Default(null) DateTime? startDate,
    @Default('') String additionalInfo,
  }) = GenerateAIPlanEditing;

  /// Submitting the request to the backend
  const factory GenerateAIPlanState.submitting() = GenerateAIPlanSubmitting;

  /// Plan generated successfully
  const factory GenerateAIPlanState.success({
    required int planId,
  }) = GenerateAIPlanSuccess;

  /// Error occurred
  const factory GenerateAIPlanState.error({
    required String message,
  }) = GenerateAIPlanError;
}
