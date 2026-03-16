import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exercises/widgets/exercise_list_item.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_exercise_data.dart';

void main() {
  group('ExerciseListItem', () {
    testWidgets('renders exercise name', (tester) async {
      await tester.pumpWidget(wrapInApp(
        ExerciseListItem(exercise: mockExerciseSummary, onTap: () {}),
      ));
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('renders chevron icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        ExerciseListItem(exercise: mockExerciseSummary, onTap: () {}),
      ));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows placeholder icon when no image', (tester) async {
      await tester.pumpWidget(wrapInApp(
        ExerciseListItem(exercise: mockExerciseWithoutImage, onTap: () {}),
      ));
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('tap fires onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrapInApp(
        ExerciseListItem(
          exercise: mockExerciseSummary,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Bench Press'));
      expect(tapped, true);
    });
  });
}
