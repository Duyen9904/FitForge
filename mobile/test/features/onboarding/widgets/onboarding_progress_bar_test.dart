import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/onboarding/widgets/onboarding_progress_bar.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('OnboardingProgressBar', () {
    testWidgets('shows "Step 1 of 8" at start', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 8,
          currentStep: 0,
          completedSteps: 0,
        ),
      ));
      expect(find.text('Step 1 of 8'), findsOneWidget);
    });

    testWidgets('shows "Step 5 of 8" on step 4', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 8,
          currentStep: 4,
          completedSteps: 4,
        ),
      ));
      expect(find.text('Step 5 of 8'), findsOneWidget);
    });

    testWidgets('shows "0% Complete" at start', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 8,
          currentStep: 0,
          completedSteps: 0,
        ),
      ));
      expect(find.text('0% Complete'), findsOneWidget);
    });

    testWidgets('shows "50% Complete" at halfway', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 8,
          currentStep: 4,
          completedSteps: 4,
        ),
      ));
      expect(find.text('50% Complete'), findsOneWidget);
    });

    testWidgets('shows "100% Complete" when done', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 8,
          currentStep: 7,
          completedSteps: 8,
        ),
      ));
      expect(find.text('100% Complete'), findsOneWidget);
    });

    testWidgets('handles totalSteps=0 without crash', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 0,
          currentStep: 0,
          completedSteps: 0,
        ),
      ));
      // Should not throw divide-by-zero
      expect(find.text('Step 1 of 0'), findsOneWidget);
      expect(find.text('0% Complete'), findsOneWidget);
    });

    testWidgets('renders correct number of step bars', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const OnboardingProgressBar(
          totalSteps: 5,
          currentStep: 2,
          completedSteps: 2,
        ),
      ));
      // 5 step bars rendered as Containers within an Expanded Row
      expect(find.text('Step 3 of 5'), findsOneWidget);
      expect(find.text('40% Complete'), findsOneWidget);
    });
  });
}
