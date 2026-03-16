import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/edit_session_exercise_sheet.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  // Smoke tests for the complex EditSessionExerciseSheet (658 lines).
  // It's a ConsumerStatefulWidget that needs ProviderScope.

  group('EditSessionExerciseSheet — Smoke Test', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EditSessionExerciseSheet(
                sessionExercise: mockSessionExercise,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Edit Exercise'), findsOneWidget);
    });

    testWidgets('shows exercise name', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EditSessionExerciseSheet(
                sessionExercise: mockSessionExercise,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('shows Save Changes button', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EditSessionExerciseSheet(
                sessionExercise: mockSessionExercise,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
