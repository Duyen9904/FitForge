import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_request.freezed.dart';
part 'onboarding_request.g.dart';

/// Request to submit user's response for an onboarding step
/// The responseData structure depends on the step type:
/// - PERSONAL_INFO: {"name": "...", "dateOfBirth": "...", "gender": "..."}
/// - BODY_METRICS: {"weight": 70.5, "height": 175, "targetWeight": 68}
/// - FITNESS_LEVEL: {"selectedOption": "INTERMEDIATE"}
/// - FITNESS_GOAL: {"selectedOptions": ["BUILD_MUSCLE", "LOSE_FAT"]}
/// - EQUIPMENT: {"selectedOptions": ["DUMBBELLS", "BARBELL", "PULL_UP_BAR"]}
/// - SCHEDULE: {"days": ["MON", "WED", "FRI"], "duration": 60, "timeOfDay": "MORNING"}
/// - HEALTH_LIMITATIONS: {"selectedOptions": ["LOWER_BACK_PAIN"]}
/// - NOTIFICATIONS: {"workoutReminders": true, "achievementAlerts": true}
@freezed
class SubmitOnboardingStepRequest with _$SubmitOnboardingStepRequest {
  const factory SubmitOnboardingStepRequest({
    /// JSON data containing the user's response for this step
    required String responseData,
  }) = _SubmitOnboardingStepRequest;

  factory SubmitOnboardingStepRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitOnboardingStepRequestFromJson(json);
}
