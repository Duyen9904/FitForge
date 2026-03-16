import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/generate_ai_plan/ai_plan_header.dart';
import 'package:mobile/features/workouts/widgets/generate_ai_plan/ai_plan_error_view.dart';
import 'package:mobile/features/workouts/widgets/generate_ai_plan/ai_plan_loading_view.dart';
import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ========================= AIPlanHeader =========================

  group('AIPlanHeader', () {
    testWidgets('renders "AI-Powered Generation" title', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanHeader()));
      expect(find.text('AI-Powered Generation'), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanHeader()));
      expect(
        find.text('Customize your plan parameters and let AI create a personalized workout.'),
        findsOneWidget,
      );
    });

    testWidgets('renders psychology icon', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanHeader()));
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });
  });

  // ========================= AIPlanLoadingView =========================

  group('AIPlanLoadingView', () {
    testWidgets('shows "Generating your plan..." text', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanLoadingView()));
      expect(find.text('Generating your plan...'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanLoadingView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows description text', (tester) async {
      await tester.pumpWidget(wrapInApp(const AIPlanLoadingView()));
      expect(
        find.textContaining('Our AI is crafting a personalized'),
        findsOneWidget,
      );
    });
  });

  // ========================= AIPlanErrorView =========================

  group('AIPlanErrorView', () {
    testWidgets('shows "Generation Failed" title', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AIPlanErrorView(message: 'Server error', onRetry: () {}),
      ));
      expect(find.text('Generation Failed'), findsOneWidget);
    });

    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AIPlanErrorView(message: 'Network timeout', onRetry: () {}),
      ));
      expect(find.text('Network timeout'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AIPlanErrorView(message: 'Error', onRetry: () {}),
      ));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows "Try Again" button', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AIPlanErrorView(message: 'Error', onRetry: () {}),
      ));
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('tapping "Try Again" fires onRetry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(wrapInApp(
        AIPlanErrorView(message: 'Error', onRetry: () => retried = true),
      ));
      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });
  });
}
