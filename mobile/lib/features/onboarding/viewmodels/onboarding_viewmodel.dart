import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/enums/onboarding_input_type.dart';
import '../models/onboarding_response.dart';
import '../repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

/// Provider for OnboardingViewModel
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return OnboardingViewModel(repository: repository);
});

/// ViewModel for managing onboarding state.
///
/// Acts as the single source of truth for:
/// - Flow navigation (current step, back/forward)
/// - Step form data (what the user has entered/selected)
/// - Form validity (whether Continue should be enabled)
/// - Submission (validate + send to backend)
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingViewModel({required OnboardingRepository repository})
      : _repository = repository,
        super(const OnboardingState.initial());

  // ─── Form Data Management ─────────────────────────────────────────

  /// Called by step widgets on every user interaction.
  /// Stores the data and computes validity for the current step.
  void updateStepData(Map<String, dynamic>? data) {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    final currentStep = currentState.flow.steps[currentState.currentStepIndex];
    final isValid = _validateStepData(currentStep, data);

    state = OnboardingLoaded(
      flow: currentState.flow,
      currentStepIndex: currentState.currentStepIndex,
      currentStepData: data,
      isCurrentStepValid: isValid,
    );
  }

  /// Called by the Continue button. Submits the current step's data.
  Future<void> submitCurrentStep() async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;
    if (!currentState.isCurrentStepValid || currentState.currentStepData == null) return;

    final step = currentState.flow.steps[currentState.currentStepIndex];
    final stepId = step.stepId ?? 0;
    await submitStep(stepId, currentState.currentStepData!);
  }

  /// Called by the Skip button. Skips the current step.
  Future<void> skipCurrentStep() async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    final step = currentState.flow.steps[currentState.currentStepIndex];
    final stepId = step.stepId ?? 0;
    await skipStep(stepId);
  }

  /// Determine if step data is valid based on the step's input type.
  bool _validateStepData(OnboardingStepResponse step, Map<String, dynamic>? data) {
    if (data == null) return false;

    final inputType = step.inputType ?? OnboardingInputType.text;
    switch (inputType) {
      case OnboardingInputType.singleChoice:
        return data['optionId'] != null;
      case OnboardingInputType.multipleChoice:
        // Multiple choice allows empty selection
        return true;
      case OnboardingInputType.toggle:
        // Toggles always have valid state
        return true;
      case OnboardingInputType.text:
        // All values must be non-empty strings
        if (data.isEmpty) return false;
        return data.values.every(
          (v) => v is String && v.trim().isNotEmpty,
        );
      case OnboardingInputType.number:
        // All values must be valid numbers
        if (data.isEmpty) return false;
        return data.values.every((v) => v is num);
    }
  }

  // ─── Flow Navigation ──────────────────────────────────────────────

  /// Load the onboarding flow from the backend
  Future<void> loadFlow() async {
    state = const OnboardingState.loading();

    try {
      final flow = await _repository.getOnboardingFlow();

      // Check if already complete
      if (flow.isComplete == true) {
        state = const OnboardingState.complete();
        return;
      }

      // Find the first incomplete step index (always from step statuses)
      final currentIndex = _findFirstIncompleteStep(flow);

      state = OnboardingState.loaded(
        flow: flow,
        currentStepIndex: currentIndex,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load onboarding flow',
        name: 'OnboardingViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = OnboardingState.error(e.toString());
    }
  }

  /// Submit response for a step
  Future<void> submitStep(int stepId, Map<String, dynamic> responseData) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded && currentState is! OnboardingSubmitting) {
      return;
    }

    final flow = currentState is OnboardingLoaded
        ? currentState.flow
        : (currentState as OnboardingSubmitting).flow;
    final currentIndex = currentState is OnboardingLoaded
        ? currentState.currentStepIndex
        : (currentState as OnboardingSubmitting).currentStepIndex;

    state = OnboardingState.submitting(
      flow: flow,
      currentStepIndex: currentIndex,
      submittingStepId: stepId,
      currentStepData: responseData,
    );

    try {
      final progress = await _repository.submitStep(
        stepId,
        jsonEncode(responseData),
      );

      // Final step: last step in progress, no step after it — write to local storage
      final isFinalStep = currentIndex == flow.steps.length - 1;
      if (isFinalStep) {
        await _repository.markOnboardingCompleteLocally();
      }

      // Check if onboarding is now complete (API or final step finished)
      if (progress.onboardingComplete == true) {
        await _repository.completeOnboarding();
        state = const OnboardingState.complete();
        return;
      }
      if (isFinalStep) {
        state = const OnboardingState.complete();
        return;
      }

      final (patchedFlow, nextIndex) = _advanceToNextStep(flow, currentIndex, progress);
      // Reset step data when moving to next step
      state = OnboardingState.loaded(flow: patchedFlow, currentStepIndex: nextIndex);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to submit onboarding step',
        name: 'OnboardingViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = OnboardingState.error(e.toString());
    }
  }

  /// Skip an optional step
  Future<void> skipStep(int stepId) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    state = OnboardingState.submitting(
      flow: currentState.flow,
      currentStepIndex: currentState.currentStepIndex,
      submittingStepId: stepId,
    );

    try {
      final progress = await _repository.skipStep(stepId);

      // Final step: last step in progress, no step after it — write to local storage
      final currentStepIndex = currentState.currentStepIndex;
      final isFinalStep = currentStepIndex == currentState.flow.steps.length - 1;
      if (isFinalStep) {
        await _repository.markOnboardingCompleteLocally();
      }

      // Check if onboarding is now complete (API or final step finished)
      if (progress.onboardingComplete == true) {
        await _repository.completeOnboarding();
        state = const OnboardingState.complete();
        return;
      }
      if (isFinalStep) {
        state = const OnboardingState.complete();
        return;
      }

      final (patchedFlow, nextIndex) = _advanceToNextStep(
        currentState.flow,
        currentStepIndex,
        progress,
      );
      // Reset step data when moving to next step
      state = OnboardingState.loaded(flow: patchedFlow, currentStepIndex: nextIndex);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to skip onboarding step',
        name: 'OnboardingViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = OnboardingState.error(e.toString());
    }
  }

  /// Navigate to a specific step (for back navigation)
  void goToStep(int index) {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    if (index >= 0 && index < (currentState.flow.steps.length)) {
      // Reset step data when navigating
      state = OnboardingState.loaded(
        flow: currentState.flow,
        currentStepIndex: index,
      );
    }
  }

  /// Go to the next step
  void nextStep() {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    final nextIndex = currentState.currentStepIndex + 1;
    if (nextIndex < currentState.flow.steps.length) {
      state = OnboardingState.loaded(
        flow: currentState.flow,
        currentStepIndex: nextIndex,
      );
    }
  }

  /// Go to the previous step
  void previousStep() {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    final prevIndex = currentState.currentStepIndex - 1;
    if (prevIndex >= 0) {
      state = OnboardingState.loaded(
        flow: currentState.flow,
        currentStepIndex: prevIndex,
      );
    }
  }

  /// Complete onboarding immediately (for manual completion)
  Future<void> completeOnboarding() async {
    try {
      await _repository.completeOnboarding();
      state = const OnboardingState.complete();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to complete onboarding',
        name: 'OnboardingViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = OnboardingState.error(e.toString());
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Find the index of the first incomplete step
  int _findFirstIncompleteStep(OnboardingFlowResponse flow) {
    for (int i = 0; i < flow.steps.length; i++) {
      final step = flow.steps[i];
      if (step.status == null || !step.status!.isDone) {
        return i;
      }
    }
    return 0;
  }

  /// Advance to next step by patching the flow in memory (no fullscreen reload).
  /// Returns (patchedFlow, nextIndex).
  (OnboardingFlowResponse, int) _advanceToNextStep(
    OnboardingFlowResponse flow,
    int currentIndex,
    OnboardingProgressResponse progress,
  ) {
    final steps = flow.steps;
    int nextIndex = currentIndex + 1;
    if (progress.nextStepId != null) {
      final found = steps.indexWhere((s) => s.stepId == progress.nextStepId);
      if (found >= 0) nextIndex = found;
    }
    if (nextIndex >= steps.length) nextIndex = steps.length - 1;
    if (nextIndex < 0) nextIndex = 0;

    final currentStep = steps[currentIndex];
    final updatedStep = currentStep.copyWith(
      status: progress.status,
      responseData: progress.responseData,
      completedAt: progress.completedAt,
    );
    final newSteps = [
      ...steps.sublist(0, currentIndex),
      updatedStep,
      ...steps.sublist(currentIndex + 1),
    ];
    final patchedFlow = flow.copyWith(
      steps: newSteps,
      completedSteps: (flow.completedSteps ?? 0) + 1,
    );
    return (patchedFlow, nextIndex);
  }
}
