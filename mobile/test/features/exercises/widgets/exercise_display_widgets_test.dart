import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exercises/widgets/difficulty_badge.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  // ========================= DifficultyBadge =========================

  group('DifficultyBadge', () {
    testWidgets('shows "Beginner" for BEGINNER level', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const DifficultyBadge(difficultyLevel: 'BEGINNER'),
      ));
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows "Intermediate" for INTERMEDIATE level', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const DifficultyBadge(difficultyLevel: 'INTERMEDIATE'),
      ));
      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('shows "Advanced" for ADVANCED level', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const DifficultyBadge(difficultyLevel: 'ADVANCED'),
      ));
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('renders in compact mode', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const DifficultyBadge(difficultyLevel: 'BEGINNER', compact: true),
      ));
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('falls back to Beginner for unknown level', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const DifficultyBadge(difficultyLevel: 'UNKNOWN'),
      ));
      expect(find.text('Beginner'), findsOneWidget);
    });
  });
}
