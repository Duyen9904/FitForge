import 'package:flutter/material.dart';
import '../../../shared/enums/onboarding_input_type.dart';
import '../models/onboarding_response.dart';
import 'steps/input_types/multiple_choice_step.dart';
import 'steps/input_types/number_input_step.dart';
import 'steps/input_types/single_choice_step.dart';
import 'steps/input_types/text_input_step.dart';
import 'steps/input_types/toggle_step.dart';

/// Thin dispatcher widget that resolves effective input type and builds
/// the appropriate step widget. No callbacks, no buttons — step widgets
/// talk directly to the ViewModel via Riverpod.
class OnboardingStepContent extends StatelessWidget {
  final OnboardingStepResponse step;

  const OnboardingStepContent({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveType = step.inputType ?? OnboardingInputType.text;
    final existingData = step.responseData;

    switch (effectiveType) {
      case OnboardingInputType.text:
        return TextInputStep(step: step, existingData: existingData);
      case OnboardingInputType.number:
        return NumberInputStep(step: step, existingData: existingData);
      case OnboardingInputType.singleChoice:
        return SingleChoiceStep(step: step, existingData: existingData);
      case OnboardingInputType.multipleChoice:
        return MultipleChoiceStep(step: step, existingData: existingData);
      case OnboardingInputType.toggle:
        return ToggleStep(step: step, existingData: existingData);
    }
  }
}
