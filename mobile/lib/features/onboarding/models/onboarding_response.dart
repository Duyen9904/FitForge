import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/enums/onboarding_input_type.dart';
import '../../../shared/enums/onboarding_step_status.dart';
import '../../../shared/enums/onboarding_step_type.dart';

part 'onboarding_response.freezed.dart';
part 'onboarding_response.g.dart';

/// Complete onboarding flow response - matches backend OnboardingFlowResponse
@freezed
class OnboardingFlowResponse with _$OnboardingFlowResponse {
  const factory OnboardingFlowResponse({
    /// Total number of steps in the onboarding flow
    int? totalSteps,

    /// Number of steps the user has completed
    int? completedSteps,

    /// Index of the current step (0-indexed) - FE can use this to navigate directly
    int? currentStepIndex,

    /// Whether the user has completed all required steps
    bool? isComplete,

    /// All onboarding steps with their status and options
    @Default([]) List<OnboardingStepResponse> steps,
  }) = _OnboardingFlowResponse;

  factory OnboardingFlowResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFlowResponseFromJson(json);
}

/// Individual onboarding step response - matches backend OnboardingStepResponse
@freezed
class OnboardingStepResponse with _$OnboardingStepResponse {
  const factory OnboardingStepResponse({
    int? stepId,
    String? stepKey,
    String? title,
    String? subtitle,
    String? helpText,
    OnboardingStepType? stepType,
    /// Renderable input type for this step (for frontend UI).
    OnboardingInputType? inputType,
    int? displayOrder,
    bool? isRequired,
    bool? isActive,
    String? iconUrl,

    /// User's progress on this step
    OnboardingStepStatus? status,
    String? responseData,
    DateTime? completedAt,

    /// Options for selection-based steps
    @Default([]) List<OnboardingOptionResponse> options,
  }) = _OnboardingStepResponse;

  factory OnboardingStepResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepResponseFromJson(json);
}

/// Onboarding option response - matches backend OnboardingOptionResponse
@freezed
class OnboardingOptionResponse with _$OnboardingOptionResponse {
  const factory OnboardingOptionResponse({
    int? optionId,
    String? optionKey,
    String? label,
    String? description,
    String? iconUrl,
    int? displayOrder,
    bool? isActive,
    String? metadata,
  }) = _OnboardingOptionResponse;

  factory OnboardingOptionResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingOptionResponseFromJson(json);
}

/// Response after submitting or skipping a step - matches backend OnboardingProgressResponse
@freezed
class OnboardingProgressResponse with _$OnboardingProgressResponse {
  const factory OnboardingProgressResponse({
    int? stepId,
    String? stepKey,
    OnboardingInputType? inputType,
    OnboardingStepStatus? status,
    String? responseData,
    DateTime? completedAt,

    /// Next step to complete (null if this was the last step)
    int? nextStepId,

    /// Whether all required steps are now complete
    bool? onboardingComplete,
  }) = _OnboardingProgressResponse;

  factory OnboardingProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingProgressResponseFromJson(json);
}
