import 'package:json_annotation/json_annotation.dart';

/// Onboarding input type - matches backend OnboardingInputType enum.
/// Renderable input type for steps (for frontend UI).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OnboardingInputType {
  /// Free-text fields (e.g. name, DOB, gender)
  text,

  /// Numeric fields (e.g. weight, height)
  number,

  /// One option from a list (radio / dropdown)
  singleChoice,

  /// Multiple options (checkboxes / multi-select)
  multipleChoice,

  /// Boolean toggles per option (e.g. notifications)
  toggle,
}
