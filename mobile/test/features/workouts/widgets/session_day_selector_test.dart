import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/session_day_selector.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  Widget buildSelector({
    List<WorkoutSessionResponse>? sessions,
    String weekLabel = 'Week 1',
    int currentWeek = 1,
    int totalWeeks = 4,
    int selectedIndex = 0,
    ValueChanged<int>? onDaySelected,
    VoidCallback? onPrevWeek,
    VoidCallback? onNextWeek,
  }) {
    return wrapInApp(
      SessionDaySelector(
        weekSessions: sessions ?? [
          mockWorkoutSession,
          mockRestDaySession,
          mockMissedSession,
        ],
        weekLabel: weekLabel,
        currentWeekNumber: currentWeek,
        totalWeeks: totalWeeks,
        selectedIndex: selectedIndex,
        onDaySelected: onDaySelected ?? (_) {},
        onPrevWeek: onPrevWeek ?? () {},
        onNextWeek: onNextWeek ?? () {},
      ),
    );
  }

  group('SessionDaySelector — Rendering', () {
    testWidgets('shows week label', (tester) async {
      await tester.pumpWidget(buildSelector(weekLabel: 'Week 2'));
      expect(find.text('Week 2'), findsOneWidget);
    });

    testWidgets('renders day chip with "Day 1"', (tester) async {
      await tester.pumpWidget(buildSelector());
      expect(find.textContaining('Day 1'), findsOneWidget);
    });

    testWidgets('rest day chip shows "Day 2 · Rest"', (tester) async {
      await tester.pumpWidget(buildSelector());
      expect(find.textContaining('Day 2 · Rest'), findsOneWidget);
    });

    testWidgets('missed day chip shows "Day 3 · Missed"', (tester) async {
      await tester.pumpWidget(buildSelector());
      expect(find.textContaining('Day 3 · Missed'), findsOneWidget);
    });
  });

  group('SessionDaySelector — Week Navigation', () {
    testWidgets('prev arrow disabled on week 1', (tester) async {
      await tester.pumpWidget(buildSelector(currentWeek: 1));
      // Find the left chevron IconButton
      final icon = find.byIcon(Icons.chevron_left);
      expect(icon, findsOneWidget);
      final button = tester.widget<IconButton>(find.ancestor(
        of: icon,
        matching: find.byType(IconButton),
      ).first);
      expect(button.onPressed, isNull);
    });

    testWidgets('next arrow disabled on last week', (tester) async {
      await tester.pumpWidget(buildSelector(currentWeek: 4, totalWeeks: 4));
      final icon = find.byIcon(Icons.chevron_right);
      expect(icon, findsOneWidget);
      final button = tester.widget<IconButton>(find.ancestor(
        of: icon,
        matching: find.byType(IconButton),
      ).first);
      expect(button.onPressed, isNull);
    });

    testWidgets('prev and next arrows enabled on middle week', (tester) async {
      await tester.pumpWidget(buildSelector(currentWeek: 2, totalWeeks: 4));

      final leftButton = tester.widget<IconButton>(find.ancestor(
        of: find.byIcon(Icons.chevron_left),
        matching: find.byType(IconButton),
      ).first);
      expect(leftButton.onPressed, isNotNull);

      final rightButton = tester.widget<IconButton>(find.ancestor(
        of: find.byIcon(Icons.chevron_right),
        matching: find.byType(IconButton),
      ).first);
      expect(rightButton.onPressed, isNotNull);
    });

    testWidgets('tapping prev fires onPrevWeek', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(buildSelector(
        currentWeek: 2,
        onPrevWeek: () => pressed = true,
      ));
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(pressed, true);
    });

    testWidgets('tapping next fires onNextWeek', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(buildSelector(
        currentWeek: 2,
        onNextWeek: () => pressed = true,
      ));
      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(pressed, true);
    });
  });

  group('SessionDaySelector — Day Selection', () {
    testWidgets('tapping a day chip fires onDaySelected with correct index', (tester) async {
      int? selectedIdx;
      await tester.pumpWidget(buildSelector(
        onDaySelected: (idx) => selectedIdx = idx,
      ));

      // Tap on "Day 2 · Rest" chip
      await tester.tap(find.textContaining('Day 2'));
      await tester.pumpAndSettle();
      expect(selectedIdx, 1);
    });
  });
}
