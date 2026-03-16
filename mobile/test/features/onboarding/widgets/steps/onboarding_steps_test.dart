import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/onboarding/widgets/steps/fitness_goal_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/fitness_level_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/body_metrics_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/equipment_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/health_limitations_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/personal_info_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/schedule_step.dart';
import 'package:mobile/features/onboarding/widgets/steps/notifications_step.dart';
import 'package:mobile/features/onboarding/models/onboarding_response.dart';

void main() {
  /// Mock step data with correct OnboardingStepResponse constructor
  const mockStep = OnboardingStepResponse(
    stepId: 1,
    stepKey: 'test_step',
    title: 'Test Step',
    subtitle: 'Test subtitle',
    displayOrder: 0,
  );

  Widget wrapStep(Widget step) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: step)),
      ),
    );
  }

  group('Onboarding Steps — Smoke Tests', () {
    testWidgets('FitnessGoalStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(FitnessGoalStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(FitnessGoalStep), findsOneWidget);
    });

    testWidgets('FitnessLevelStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(FitnessLevelStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(FitnessLevelStep), findsOneWidget);
    });

    testWidgets('BodyMetricsStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(BodyMetricsStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(BodyMetricsStep), findsOneWidget);
    });

    testWidgets('EquipmentStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(EquipmentStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentStep), findsOneWidget);
    });

    testWidgets('HealthLimitationsStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(HealthLimitationsStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(HealthLimitationsStep), findsOneWidget);
    });

    testWidgets('PersonalInfoStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(PersonalInfoStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalInfoStep), findsOneWidget);
    });

    testWidgets('ScheduleStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(ScheduleStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleStep), findsOneWidget);
    });

    testWidgets('NotificationsStep renders without crashing', (tester) async {
      await tester.pumpWidget(wrapStep(NotificationsStep(
        step: mockStep,
        onSubmit: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsStep), findsOneWidget);
    });
  });
}
