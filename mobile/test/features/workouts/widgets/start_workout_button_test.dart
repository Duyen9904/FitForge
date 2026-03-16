import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/start_workout_button.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  group('StartWorkoutButton', () {
    testWidgets('renders nothing when session is null', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const StartWorkoutButton(loadedSession: null),
      ));
      // SizedBox.shrink renders as a zero-size widget
      expect(find.text('START WORKOUT'), findsNothing);
      expect(find.text('Workout completed for today'), findsNothing);
    });

    testWidgets('renders nothing when session is rest day', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const StartWorkoutButton(loadedSession: mockRestDaySession),
      ));
      expect(find.text('START WORKOUT'), findsNothing);
      expect(find.text('Workout completed for today'), findsNothing);
    });

    testWidgets('shows "Workout completed" when session is completed', (tester) async {
      const completedSession = WorkoutSessionResponse(
        sessionId: 5,
        sessionName: 'Push',
        dayNumber: 1,
        isCompleted: true,
        exercises: [],
      );
      await tester.pumpWidget(wrapInApp(
        const StartWorkoutButton(loadedSession: completedSession),
      ));
      expect(find.text('Workout completed for today'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsNothing);
    });

    testWidgets('shows START WORKOUT button for active session', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const StartWorkoutButton(loadedSession: mockWorkoutSession),
      ));
      expect(find.text('START WORKOUT'), findsOneWidget);
    });

    testWidgets('START WORKOUT button is an ElevatedButton', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const StartWorkoutButton(loadedSession: mockWorkoutSession),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
