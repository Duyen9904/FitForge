import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/screens/register_screen.dart';
import 'package:mobile/features/auth/viewmodels/auth_state.dart';
import 'package:mobile/features/auth/viewmodels/auth_viewmodel.dart';

/// A fake AuthViewModel that does nothing — used to control state in tests.
class FakeAuthViewModel extends StateNotifier<AuthState>
    implements AuthViewModel {
  FakeAuthViewModel([AuthState initial = const AuthState.initial()])
      : super(initial);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late FakeAuthViewModel fakeAuthViewModel;

  Widget buildRegisterScreen({
    AuthState initialState = const AuthState.initial(),
  }) {
    fakeAuthViewModel = FakeAuthViewModel(initialState);
    return ProviderScope(
      overrides: [
        authViewModelProvider
            .overrideWith((_) => fakeAuthViewModel),
      ],
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  group('RegisterScreen — UI Rendering', () {
    testWidgets('renders "Join GymPlan" title', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Join GymPlan'), findsOneWidget);
    });

    testWidgets('renders "Create Account" app bar title', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(
        find.text('Create your account to start your fitness journey'),
        findsOneWidget,
      );
    });

    testWidgets('renders all 4 field labels', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('renders Sign In link', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders "Already have an account?" text', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Already have an account? '), findsOneWidget);
    });
  });

  group('RegisterScreen — Form Validation', () {
    testWidgets('shows error when username is empty', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      // Clear pre-filled username (first TextFormField)
      await tester.enterText(find.byType(TextFormField).at(0), '');

      // Scroll down to the Create Account button and tap
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
    });

    testWidgets('shows error for short username', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(0), 'ab');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Username must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(1), '');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(2), '');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error for short password', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(2), '12');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      // Set different passwords
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'differentpwd');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows error when confirm password is empty', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      await tester.enterText(find.byType(TextFormField).at(3), '');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Please confirm your password'), findsOneWidget);
    });
  });

  group('RegisterScreen — Password Visibility', () {
    testWidgets('both password fields are obscured by default', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      // Two visibility_outlined icons for password + confirm password
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('tapping password eye icon toggles visibility', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      // Tap first eye icon (Password field)
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();

      // First field toggled: 1 visibility_off + 1 visibility_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('tapping confirm password eye icon toggles visibility', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());

      // Tap second eye icon (Confirm Password field)
      await tester.tap(find.byIcon(Icons.visibility_outlined).last);
      await tester.pump();

      // Second field toggled: 1 visibility_off + 1 visibility_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('RegisterScreen — Loading State', () {
    testWidgets('shows spinner and disables button when loading', (tester) async {
      await tester.pumpWidget(
        buildRegisterScreen(initialState: const AuthState.loading()),
      );

      // Button text should be replaced with spinner
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Button should be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
