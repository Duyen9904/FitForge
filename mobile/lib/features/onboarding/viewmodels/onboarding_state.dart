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
  }) = OnboardingLoaded;

  /// Submitting a step response
  const factory OnboardingState.submitting({
    required OnboardingFlowResponse flow,
    required int currentStepIndex,
    required int submittingStepId,
  }) = OnboardingSubmitting;

  /// Onboarding completed successfully
  const factory OnboardingState.complete() = OnboardingComplete;

  /// Error occurred
  const factory OnboardingState.error(String message) = OnboardingError;
}
