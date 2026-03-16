import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/create_plan_steps/plan_wizard_step_indicator.dart';
import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ========================= PlanWizardStepIndicator =========================
  // PlanWizardBottomButtons is a ConsumerWidget that takes a
  // CreateWorkoutPlanViewModel, which is complex to mock.
  // We focus tests on PlanWizardStepIndicator which is a pure StatelessWidget.

  group('PlanWizardStepIndicator', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const PlanWizardStepIndicator(
          currentStep: 0,
          stepTitles: ['Details', 'Sessions', 'Exercises'],
        ),
      ));
      expect(find.byType(PlanWizardStepIndicator), findsOneWidget);
    });

    testWidgets('shows step labels', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const PlanWizardStepIndicator(
          currentStep: 0,
          stepTitles: ['Details', 'Sessions', 'Exercises'],
        ),
      ));
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
    });

    testWidgets('shows step numbers', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const PlanWizardStepIndicator(
          currentStep: 1,
          stepTitles: ['Details', 'Sessions', 'Exercises'],
        ),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
