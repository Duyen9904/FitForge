import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/workouts/widgets/session_exercise_list.dart';
import 'package:mobile/features/workouts/viewmodels/workout_plan_detail_state.dart';
import 'package:mobile/features/workouts/models/workout_plan_models.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/mock_workout_data.dart';

void main() {
  Widget buildList({
    required SessionLoadingState loadingState,
    WorkoutSessionResponse? session,
    String? errorMessage,
    VoidCallback? onRetry,
    void Function(SessionExerciseResponse)? onEditExercise,
    void Function(SessionExerciseResponse)? onDeleteExercise,
  }) {
    return wrapInApp(
      SessionExerciseList(
        loadingState: loadingState,
        session: session,
        errorMessage: errorMessage,
        onRetry: onRetry,
        onEditExercise: onEditExercise,
        onDeleteExercise: onDeleteExercise,
      ),
    );
  }

  group('SessionExerciseList — Idle State', () {
    testWidgets('renders nothing when idle', (tester) async {
      await tester.pumpWidget(buildList(loadingState: SessionLoadingState.idle));
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('SessionExerciseList — Loading State', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(buildList(loadingState: SessionLoadingState.loading));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SessionExerciseList — Error State', () {
    testWidgets('shows default error message', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.error,
      ));
      expect(find.text('Failed to load exercises'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows custom error message', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.error,
        errorMessage: 'Network timeout',
      ));
      expect(find.text('Network timeout'), findsOneWidget);
    });

    testWidgets('shows Retry button when onRetry provided', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.error,
        onRetry: () {},
      ));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('no Retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.error,
      ));
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('Retry button fires callback', (tester) async {
      bool retried = false;
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.error,
        onRetry: () => retried = true,
      ));
      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });
  });

  group('SessionExerciseList — Loaded State', () {
    testWidgets('shows "No exercises" when session is null', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: null,
      ));
      expect(find.text('No exercises for this session'), findsOneWidget);
    });

    testWidgets('shows exercise count header', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: mockSessionWithExercises,
      ));
      expect(find.text('3 Exercises'), findsOneWidget);
    });

    testWidgets('shows exercise names', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: mockSessionWithExercises,
      ));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('shows exercise subtitle with sets/reps/weight', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: mockSessionWithExercises,
      ));
      expect(find.text('3 sets · 12 reps · 60.0 kg · 90s rest'), findsOneWidget);
    });

    testWidgets('shows edit button when onEditExercise provided', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: mockSessionWithExercises,
        onEditExercise: (_) {},
      ));
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(3));
    });

    testWidgets('no edit button when onEditExercise is null', (tester) async {
      await tester.pumpWidget(buildList(
        loadingState: SessionLoadingState.loaded,
        session: mockSessionWithExercises,
      ));
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });
}
