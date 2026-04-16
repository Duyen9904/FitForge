import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/onboarding_response.dart';

part 'onboarding_state.freezed.dart';

/// State for onboarding flow
@freezed
class OnboardingState with _$OnboardingState {
  /// Initial state before loading
  const factory OnboardingState.initial() = OnboardingInitial;

  /// Loading the onboarding flow
  const factory OnboardingState.loading() = OnboardingLoading;

  /// Flow loaded successfully with all steps
  const factory OnboardingState.loaded({
    required OnboardingFlowResponse flow,
    required int currentStepIndex,
    /// Current step's form data reported by the active step widget
    Map<String, dynamic>? currentStepData,
    /// Whether the current step has valid data to submit
    @Default(false) bool isCurrentStepValid,
  }) = OnboardingLoaded;

  /// Submitting a step response
  const factory OnboardingState.submitting({
    required OnboardingFlowResponse flow,
    required int currentStepIndex,
    required int submittingStepId,
    /// Preserve step data during submission
    Map<String, dynamic>? currentStepData,
  }) = OnboardingSubmitting;

  /// Onboarding completed successfully
  const factory OnboardingState.complete() = OnboardingComplete;

  /// Error occurred
  const factory OnboardingState.error(String message) = OnboardingError;
}
