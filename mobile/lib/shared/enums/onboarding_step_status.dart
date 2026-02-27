import 'package:json_annotation/json_annotation.dart';

/// Onboarding step status - matches backend OnboardingStepStatus enum
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OnboardingStepStatus {
  /// Step has not been completed yet
  pending,

  /// User has completed the step
  completed,

  /// User has skipped this optional step
  skipped;

  String get displayName {
    switch (this) {
      case OnboardingStepStatus.pending:
        return 'Pending';
      case OnboardingStepStatus.completed:
        return 'Completed';
      case OnboardingStepStatus.skipped:
        return 'Skipped';
    }
  }

  bool get isDone => this == completed || this == skipped;
}
