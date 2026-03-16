import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/workout_plan_filter_sheet.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  Widget buildFilterSheet({
    WorkoutPlanFilterRequest? initialFilter,
    Function(WorkoutPlanFilterRequest)? onApply,
    VoidCallback? onClear,
  }) {
    // Filter sheet is a ConsumerStatefulWidget that needs ProviderScope
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: WorkoutPlanFilterSheet(
              initialFilter: initialFilter,
              onApply: onApply ?? (_) {},
              onClear: onClear ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  group('WorkoutPlanFilterSheet — Rendering', () {
    testWidgets('shows "Filter Workout Plans" header', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('Filter Workout Plans'), findsOneWidget);
    });

    testWidgets('shows Active Status section', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('Active Status'), findsOneWidget);
    });

    testWidgets('shows filter chips: All, Active, Inactive', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      // "All" appears multiple times (Active Status + AI Generated sections)
      expect(find.text('All'), findsWidgets);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('shows AI Generated section', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('AI Generated'), findsOneWidget);
    });

    testWidgets('shows Created Date Range section', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('Created Date Range'), findsOneWidget);
    });

    testWidgets('shows Search field', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(buildFilterSheet());
      await tester.pumpAndSettle();
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });
}
