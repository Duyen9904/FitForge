import 'package:flutter/material.dart';
import '../../../shared/enums/onboarding_input_type.dart';
import '../../../shared/enums/onboarding_step_type.dart';
import '../models/onboarding_response.dart';
import 'steps/input_types/multiple_choice_step.dart';
import 'steps/input_types/number_input_step.dart';
import 'steps/input_types/single_choice_step.dart';
import 'steps/input_types/text_input_step.dart';
import 'steps/input_types/toggle_step.dart';

/// Single step-content widget that resolves effective input type and builds
/// the appropriate presentational widget. All step/input-type logic is contained here.
class OnboardingStepContent extends StatelessWidget {
  final OnboardingStepResponse step;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onSkip;

  const OnboardingStepContent({
    super.key,
    required this.step,
    required this.onSubmit,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveType = _effectiveInputType(step);
    final existingData = step.responseData;

    switch (effectiveType) {
      case OnboardingInputType.text:
        return TextInputStep(
          step: step,
          onSubmit: onSubmit,
          onSkip: onSkip,
          existingData: existingData,
        );
      case OnboardingInputType.number:
        return NumberInputStep(
          step: step,
          onSubmit: onSubmit,
          onSkip: onSkip,
          existingData: existingData,
        );
      case OnboardingInputType.singleChoice:
        return SingleChoiceStep(
          step: step,
          onSubmit: onSubmit,
          onSkip: onSkip,
          existingData: existingData,
        );
      case OnboardingInputType.multipleChoice:
        return MultipleChoiceStep(
          step: step,
          onSubmit: onSubmit,
          onSkip: onSkip,
          existingData: existingData,
        );
      case OnboardingInputType.toggle:
        return ToggleStep(
          step: step,
          onSubmit: onSubmit,
          onSkip: onSkip,
          existingData: existingData,
        );
    }
  }

  /// Resolve effective input type: use step.inputType when set,
  /// otherwise derive from step.stepType for backward compatibility.
  static OnboardingInputType _effectiveInputType(OnboardingStepResponse step) {
    if (step.inputType != null) {
      return step.inputType!;
    }
    final stepType = step.stepType;
    if (stepType == null) {
      return OnboardingInputType.text;
    }
    switch (stepType) {
      case OnboardingStepType.personalInfo:
        return OnboardingInputType.text;
      case OnboardingStepType.bodyMetrics:
        return OnboardingInputType.number;
      case OnboardingStepType.fitnessLevel:
        return OnboardingInputType.singleChoice;
      case OnboardingStepType.fitnessGoal:
      case OnboardingStepType.equipment:
      case OnboardingStepType.schedule:
      case OnboardingStepType.healthLimitations:
        return OnboardingInputType.multipleChoice;
      case OnboardingStepType.notifications:
        return OnboardingInputType.toggle;
    }
  }
}
