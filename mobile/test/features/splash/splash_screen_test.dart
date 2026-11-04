import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/config/routes.dart';
import 'package:mobile/core/state/app_flow_state.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';
import 'package:mobile/features/splash/screens/splash_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAppFlowStateNotifier extends Mock implements AppFlowStateNotifier {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAppFlowStateNotifier mockFlowStateNotifier;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFlowStateNotifier = MockAppFlowStateNotifier();

    when(() => mockFlowStateNotifier.checkFlowStatus(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: Routes.splash,
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        appFlowStateProvider.overrideWith((ref) => mockFlowStateNotifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('SplashScreen displays logo, app title, and navigates to login when unauthenticated',
      (tester) async {
    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createTestWidget());

    // Logo & Title
    expect(find.text('GymPlan'), findsOneWidget);
    expect(find.text('Your Personal Fitness Companion'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance 2 seconds for auth check
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    // Navigates to Login Screen
    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('SplashScreen displays Connection Error and Retry button on network failure',
      (tester) async {
    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => true);
    when(() => mockAuthRepository.isTokenExpired())
        .thenAnswer((_) async => false);
    when(() => mockAuthRepository.getCurrentUser())
        .thenThrow(Exception('SocketException: OS Error: Connection refused'));

    await tester.pumpWidget(createTestWidget());

    // Advance past the initial delay and checkAuthStatus call
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify error UI is displayed instead of endless progress indicator
    expect(find.text('Connection Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Continue to Login'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Now test Retry button
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const UserModel(
              userId: 1,
              username: 'test',
              email: 'test@example.com',
            ));

    await tester.tap(find.text('Retry'));
    await tester.pump();

    // Spinner shows during retry
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    // Successfully navigated to Home Screen
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
