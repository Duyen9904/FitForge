import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/onboarding/widgets/onboarding_step_content.dart';
import 'package:mobile/features/onboarding/models/onboarding_response.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  const mockStep = OnboardingStepResponse(
    stepId: 1,
    stepKey: 'test_step',
    title: 'What is your fitness goal?',
    subtitle: 'Choose one option',
    displayOrder: 0,
  );

  group('OnboardingStepContent', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingStepContent(
          step: mockStep,
          onSubmit: (_) {},
        ),
      ));
      expect(find.byType(OnboardingStepContent), findsOneWidget);
    });

    testWidgets('renders step title', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingStepContent(
          step: mockStep,
          onSubmit: (_) {},
        ),
      ));
      expect(find.text('What is your fitness goal?'), findsOneWidget);
    });

    testWidgets('renders step subtitle when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingStepContent(
          step: mockStep,
          onSubmit: (_) {},
        ),
      ));
      expect(find.text('Choose one option'), findsOneWidget);
    });
  });
}
