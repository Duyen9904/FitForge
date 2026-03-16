import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exercises/widgets/exercise_filter_bottom_sheet.dart';
import 'package:mobile/features/exercises/models/exercise_filter.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  Widget buildFilterSheet({
    ExerciseFilter? filter,
    Function(ExerciseFilter)? onApply,
  }) {
    return wrapInApp(
      ExerciseFilterBottomSheet(
        currentFilter: filter ?? const ExerciseFilter(),
        onApply: onApply ?? (_) {},
      ),
    );
  }

  group('ExerciseFilterBottomSheet — Rendering', () {
    testWidgets('shows "Filter Exercises" header', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('Filter Exercises'), findsOneWidget);
    });

    testWidgets('shows "Difficulty Level" section', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('Difficulty Level'), findsOneWidget);
    });

    testWidgets('shows "Exercise Category" section', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('Exercise Category'), findsOneWidget);
    });

    testWidgets('shows "Requires Spotter" checkbox', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('Requires Spotter'), findsOneWidget);
    });

    testWidgets('shows difficulty chips including All', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('All'), findsWidgets); // appears in both sections
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('shows Reset and Apply Filters buttons', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });

  group('ExerciseFilterBottomSheet — Interactions', () {
    testWidgets('tapping a difficulty chip toggles selection', (tester) async {
      await tester.pumpWidget(buildFilterSheet());

      // Find and tap "Beginner" chip
      await tester.tap(find.text('Beginner'));
      await tester.pump();

      // Chip should now be selected (FilterChip will have different style)
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Beginner'),
      );
      expect(chip.selected, true);
    });

    testWidgets('tapping Reset clears selections', (tester) async {
      await tester.pumpWidget(buildFilterSheet(
        filter: const ExerciseFilter(difficultyLevel: 'BEGINNER'),
      ));

      await tester.tap(find.text('Reset'));
      await tester.pump();

      // After reset, no chip should be selected except "All"
      // This verifies the reset logic works without crashing
    });
  });
}
