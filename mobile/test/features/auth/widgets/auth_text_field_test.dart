import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/widgets/auth_text_field.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('AuthTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(controller: controller, label: 'Email'),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(
          controller: controller,
          label: 'Email',
          hint: 'Enter your email',
        ),
      ));
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(
          controller: controller,
          label: 'Email',
          prefixIcon: Icons.email_outlined,
        ),
      ));
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('no prefix icon when not provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(controller: controller, label: 'Email'),
      ));
      expect(find.byIcon(Icons.email_outlined), findsNothing);
    });

    testWidgets('shows suffix icon when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(
          controller: controller,
          label: 'Password',
          suffixIcon: const Icon(Icons.visibility),
        ),
      ));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(
          controller: controller,
          label: 'Password',
          obscureText: true,
        ),
      ));
      final editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, true);
    });

    testWidgets('does not obscure text by default', (tester) async {
      await tester.pumpWidget(wrapInApp(
        AuthTextField(controller: controller, label: 'Email'),
      ));
      final editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, false);
    });

    testWidgets('shows validation error after invalid submit', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(wrapInApp(
        Form(
          key: formKey,
          child: AuthTextField(
            controller: controller,
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
          ),
        ),
      ));

      // Trigger validation with empty field
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('fires onChanged callback when text entered', (tester) async {
      String changedValue = '';
      await tester.pumpWidget(wrapInApp(
        AuthTextField(
          controller: controller,
          label: 'Email',
          onChanged: (value) => changedValue = value,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'test@email.com');
      expect(changedValue, 'test@email.com');
    });
  });
}
