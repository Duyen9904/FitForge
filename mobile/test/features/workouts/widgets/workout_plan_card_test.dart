import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/workout_plan_card.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  Widget buildCard(
    WorkoutPlanSummaryResponse plan, {
    VoidCallback? onToggleActive,
    Function(String)? onDuplicate,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: WorkoutPlanCard(
            plan: plan,
            onTap: () {},
            onToggleActive: onToggleActive,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('WorkoutPlanCard — Basic Rendering', () {
    testWidgets('renders plan name', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('Full Body Blast'), findsOneWidget);
    });

    testWidgets('renders difficulty badge', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('renders frequency', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('3x/week'), findsOneWidget);
    });

    testWidgets('renders duration in weeks', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('4 weeks'), findsOneWidget);
    });

    testWidgets('renders formatted muscle group name', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('Full Body'), findsOneWidget);
    });
  });

  group('WorkoutPlanCard — Badge Logic', () {
    testWidgets('shows "AI" badge when aiGenerated is true', (tester) async {
      await tester.pumpWidget(buildCard(mockAiGeneratedPlan));
      expect(find.text('AI'), findsOneWidget);
    });

    testWidgets('no "AI" badge when aiGenerated is false', (tester) async {
      await tester.pumpWidget(buildCard(mockWorkoutPlanSummary));
      expect(find.text('AI'), findsNothing);
    });

    testWidgets('shows "Active" badge when isActive is true', (tester) async {
      await tester.pumpWidget(buildCard(
        mockWorkoutPlanSummary,
        onToggleActive: () {},
      ));
      expect(find.text('Active'), findsOneWidget);
    });


  });

  group('WorkoutPlanCard — Interactions', () {
    testWidgets('tap fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WorkoutPlanCard(
              plan: mockWorkoutPlanSummary,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Full Body Blast'));
      expect(tapped, true);
    });

    testWidgets('tap on Active badge fires onToggleActive', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(buildCard(
        mockWorkoutPlanSummary,
        onToggleActive: () => toggled = true,
      ));

      await tester.tap(find.text('Active'));
      expect(toggled, true);
    });
  });

}
