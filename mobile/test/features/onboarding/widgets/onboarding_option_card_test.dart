import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/onboarding/widgets/onboarding_option_card.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('OnboardingOptionCard', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Lose Weight',
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.text('Lose Weight'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Lose Weight',
          description: 'Burn fat and get lean',
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.text('Burn fat and get lean'), findsOneWidget);
    });

    testWidgets('no description when null', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Lose Weight',
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.text('Burn fat and get lean'), findsNothing);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Build Muscle',
          isSelected: true,
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('no check icon when not selected', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Build Muscle',
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tap fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Stay Fit',
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Stay Fit'));
      expect(tapped, true);
    });

    testWidgets('renders default icon when no iconUrl', (tester) async {
      await tester.pumpWidget(wrapInApp(
        OnboardingOptionCard(
          label: 'Option',
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });
  });
}
