import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/plan_hero_section.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  const mockPlan = WorkoutPlanResponse(
    planId: 1,
    planName: 'Full Body Blast',
    description: 'A great plan',
    difficultyLevel: 'BEGINNER',
    isActive: true,
    durationWeeks: 4,
    frequencyPerWeek: 3,
  );

  const mockSession = WorkoutSessionResponse(
    sessionId: 1,
    sessionName: 'Push Day',
    dayNumber: 3,
    focusArea: 'Chest & Shoulders',
    estimatedDuration: 45,
    exercises: [],
  );

  Widget buildHero({
    WorkoutPlanResponse plan = mockPlan,
    WorkoutSessionResponse? session,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            PlanHeroSection(
              plan: plan,
              loadedSession: session,
              onBack: () {},
              onMenu: () {},
            ),
          ],
        ),
      ),
    );
  }

  group('PlanHeroSection — Without Session', () {
    testWidgets('shows plan name as title when no session', (tester) async {
      await tester.pumpWidget(buildHero());
      expect(find.text('Full Body Blast'), findsOneWidget);
    });

    testWidgets('shows Active badge', (tester) async {
      await tester.pumpWidget(buildHero());
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows difficulty badge', (tester) async {
      await tester.pumpWidget(buildHero());
      expect(find.text('Beginner'), findsOneWidget);
    });
  });

  group('PlanHeroSection — With Session', () {
    testWidgets('shows session title with day number', (tester) async {
      await tester.pumpWidget(buildHero(session: mockSession));
      expect(find.text('Day 03 - Push Day'), findsOneWidget);
    });

    testWidgets('shows focus area', (tester) async {
      await tester.pumpWidget(buildHero(session: mockSession));
      expect(find.text('Chest & Shoulders'), findsOneWidget);
    });

    testWidgets('shows estimated duration badge', (tester) async {
      await tester.pumpWidget(buildHero(session: mockSession));
      expect(find.text('45 Min'), findsOneWidget);
    });
  });

  group('PlanHeroSection — Inactive Plan', () {
    testWidgets('shows Inactive badge', (tester) async {
      const inactivePlan = WorkoutPlanResponse(
        planId: 2,
        planName: 'Old Plan',
        isActive: false,
      );
      await tester.pumpWidget(buildHero(plan: inactivePlan));
      expect(find.text('Inactive'), findsOneWidget);
    });
  });

  group('PlanHeroSection — Navigation', () {
    testWidgets('back button fires callback', (tester) async {
      bool backPressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              PlanHeroSection(
                plan: mockPlan,
                onBack: () => backPressed = true,
                onMenu: () {},
              ),
            ],
          ),
        ),
      ));
      // Find the back arrow button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      expect(backPressed, true);
    });
  });
}
