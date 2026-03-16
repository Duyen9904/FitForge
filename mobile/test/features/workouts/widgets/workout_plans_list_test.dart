import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/workout_plans_empty_state.dart';
import 'package:mobile/features/workouts/widgets/workout_plans_header.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import 'package:mobile/features/workouts/widgets/workout_plan_card.dart';

import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  // ========================= WorkoutPlansEmptyState =========================

  group('WorkoutPlansEmptyState', () {
    testWidgets('shows "Start Your Fitness Journey" when no plans', (tester) async {
      await tester.pumpWidget(wrapInApp(
        WorkoutPlansEmptyState(
          hasPlans: false,
          onGeneratePlan: () {},
        ),
      ));
      await tester.pumpAndSettle(); // wait for fade/slide animations

      expect(find.text('Start Your Fitness Journey'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('shows "No Active Plans" when hasPlans=true', (tester) async {
      await tester.pumpWidget(wrapInApp(
        WorkoutPlansEmptyState(
          hasPlans: true,
          onGeneratePlan: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No Active Plans'), findsOneWidget);
      expect(find.text('Create New Plan'), findsOneWidget);
    });

    testWidgets('tapping CTA fires onGeneratePlan callback', (tester) async {
      bool fired = false;
      await tester.pumpWidget(wrapInApp(
        WorkoutPlansEmptyState(
          hasPlans: false,
          onGeneratePlan: () => fired = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      expect(fired, true);
    });

    testWidgets('shows fitness icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        WorkoutPlansEmptyState(
          hasPlans: false,
          onGeneratePlan: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });
  });

  // ========================= WorkoutPlansHeader =========================

  group('WorkoutPlansHeader', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              WorkoutPlansHeader(onAddPressed: () {}),
            ],
          ),
        ),
      ));
      expect(find.byType(WorkoutPlansHeader), findsOneWidget);
    });
  });
}
