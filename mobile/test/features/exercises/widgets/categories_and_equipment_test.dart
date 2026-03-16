import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exercises/widgets/categories_tab_content.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  // CategoriesTabContent and EquipmentTabContent are Riverpod consumers
  // that fetch data from the API. Smoke tests verify they render
  // without crashing even when no data is available.

  group('CategoriesTabContent — Smoke Test', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: const Scaffold(body: CategoriesTabContent()),
        ),
      ));
      await tester.pump();
      // Should render the widget tree without errors
      expect(find.byType(CategoriesTabContent), findsOneWidget);
    });
  });
}
