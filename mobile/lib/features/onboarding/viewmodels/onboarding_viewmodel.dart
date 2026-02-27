import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_response.dart';
import '../repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

/// Provider for OnboardingViewModel
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return OnboardingViewModel(repository: repository);
});

/// ViewModel for managing onboarding state
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingViewModel({required OnboardingRepository repository})
      : _repository = repository,
        super(const OnboardingState.initial());

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
