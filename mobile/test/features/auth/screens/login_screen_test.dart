import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
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

  Widget buildLoginScreen({AuthState initialState = const AuthState.initial()}) {
    fakeAuthViewModel = FakeAuthViewModel(initialState);
    return ProviderScope(
      overrides: [
        authViewModelProvider
            .overrideWith((_) => fakeAuthViewModel),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen — UI Rendering', () {
    testWidgets('renders title "Hello, Gymer"', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Hello, Gymer'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Sign in to start your fitness journey'), findsOneWidget);
    });

    testWidgets('renders Email and Password labels', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders Forgot Password link', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('renders Sign Up link', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('renders Continue with Google button', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('renders "or" divider', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('or'), findsOneWidget);
    });
  });

  group('LoginScreen — Form Validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Clear the pre-filled email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, '');

      // Tap Sign In to trigger validation
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'not-an-email');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Clear password field (second TextFormField)
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, '');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error for short password', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, '123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('LoginScreen — Password Visibility', () {
    testWidgets('password is obscured by default', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('tapping eye icon toggles visibility', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Initially visibility_outlined (obscured)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Tap to reveal
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now visibility_off_outlined (visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });
  });

  group('LoginScreen — Loading State', () {
    testWidgets('shows loading spinner and disables button when loading', (tester) async {
      await tester.pumpWidget(
        buildLoginScreen(initialState: const AuthState.loading()),
      );

      // Sign In text should be replaced by CircularProgressIndicator
      expect(find.text('Sign In'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Button should be disabled (onPressed == null)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
