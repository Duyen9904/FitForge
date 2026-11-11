import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/ui/core/states/empty_screen.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('EmptyScreen Widget Tests', () {
    testWidgets('renders properly when all parameters are null',
        (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const EmptyScreen(
            title: null,
            description: null,
            button: null,
            buttonText: null,
            onButtonPressed: null,
            illustration: null,
            illustrationPath: null,
          ),
        ),
      );

      expect(find.byType(EmptyScreen), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders title and description when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const EmptyScreen(
            title: 'No Workouts Found',
            description: 'You have not scheduled any workouts yet.',
            illustrationPath: null,
          ),
        ),
      );

      expect(find.text('No Workouts Found'), findsOneWidget);
      expect(find.text('You have not scheduled any workouts yet.'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders button and triggers callback when pressed',
        (tester) async {
      var buttonClicked = false;

      await tester.pumpWidget(
        wrapInApp(
          EmptyScreen(
            title: 'Empty List',
            buttonText: 'Create New',
            onButtonPressed: () {
              buttonClicked = true;
            },
            illustrationPath: null,
          ),
        ),
      );

      expect(find.text('Create New'), findsOneWidget);
      await tester.tap(find.text('Create New'));
      await tester.pumpAndSettle();

      expect(buttonClicked, true);
    });

    testWidgets('renders custom button when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          EmptyScreen(
            title: 'Title',
            button: OutlinedButton(
              onPressed: () {},
              child: const Text('Custom Outlined Button'),
            ),
            illustrationPath: null,
          ),
        ),
      );

      expect(find.text('Custom Outlined Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders custom illustration widget when provided',
        (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const EmptyScreen(
            illustration: Icon(Icons.fitness_center, size: 64),
            title: 'Gym Empty',
            illustrationPath: null,
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('Gym Empty'), findsOneWidget);
    });

    testWidgets('renders as full scaffold screen when using scaffold constructor',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EmptyScreen.scaffold(
            appBar: AppBar(title: const Text('Empty Page')),
            title: 'Empty Screen Full',
            illustrationPath: null,
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Empty Page'), findsOneWidget);
      expect(find.text('Empty Screen Full'), findsOneWidget);
    });
  });
}
