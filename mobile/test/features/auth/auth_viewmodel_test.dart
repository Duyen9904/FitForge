import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/network/api_exceptions.dart';
import 'package:mobile/core/state/app_flow_state.dart';
import 'package:mobile/features/auth/models/auth_response.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';
import 'package:mobile/features/auth/viewmodels/auth_state.dart';
import 'package:mobile/features/auth/viewmodels/auth_viewmodel.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockRef extends Mock implements Ref {}
class MockAppFlowStateNotifier extends Mock implements AppFlowStateNotifier {}
class MockStateController extends Mock implements StateController<String?> {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockRef mockRef;
  late MockAppFlowStateNotifier mockFlowStateNotifier;
  late MockStateController mockEmailController;

  const testUserModel = UserModel(
    userId: 1,
    username: 'testuser',
    email: 'test@example.com',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRef = MockRef();
    mockFlowStateNotifier = MockAppFlowStateNotifier();
    mockEmailController = MockStateController();

    // Mock the appFlowStateProvider
    when(() => mockRef.read(appFlowStateProvider.notifier))
        .thenReturn(mockFlowStateNotifier);
    when(() => mockFlowStateNotifier.checkFlowStatus(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async {});
    when(() => mockFlowStateNotifier.clear()).thenReturn(null);

    // Mock currentUserEmailProvider
    when(() => mockRef.read(currentUserEmailProvider.notifier))
        .thenReturn(mockEmailController);

    viewModel = AuthViewModel(mockAuthRepository, mockRef);
  });

  group('AuthViewModel', () {
    test('initial state is AuthState.initial', () {
      expect(viewModel.state, const AuthState.initial());
    });

    group('login', () {
      test('sets authenticated state on successful login', () async {
        // Arrange
        const userSummary = AccountSummary(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
        );

        when(() => mockAuthRepository.login('test@example.com', 'password123'))
            .thenAnswer((_) async => userSummary);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUserModel);

        // Act
        await viewModel.login('test@example.com', 'password123');

        // Assert
        viewModel.state.maybeWhen(
          authenticated: (authenticatedUser) {
            expect(authenticatedUser.email, 'test@example.com');
          },
          orElse: () => fail('Expected authenticated state'),
        );
      });

      test('sets error state on login failure', () async {
        // Arrange
        when(() => mockAuthRepository.login(any(), any()))
            .thenThrow(Exception('Login failed'));

        // Act
        await viewModel.login('test@example.com', 'wrongpassword');

        // Assert
        viewModel.state.maybeWhen(
          error: (String message, Map<String, List<String>>? fieldErrors) {
            expect(message, contains('Login failed'));
          },
          orElse: () => fail('Expected error state'),
        );
      });
    });

    group('register', () {
      test('sets registrationSuccess state on successful registration', () async {
        // Arrange
        when(() => mockAuthRepository.register(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenAnswer((_) async {});

        // Act
        await viewModel.register(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        );

        // Assert
        viewModel.state.maybeWhen(
          registrationSuccess: () => expect(true, true),
          orElse: () => fail('Expected registrationSuccess state'),
        );
      });
    });

    group('logout', () {
      test('sets unauthenticated state after logout', () async {
        // Arrange
        when(() => mockAuthRepository.logout(any())).thenAnswer((_) async {});

        // Act
        await viewModel.logout('test@example.com');

        // Assert
        viewModel.state.maybeWhen(
          unauthenticated: () => expect(true, true),
          orElse: () => fail('Expected unauthenticated state'),
        );
      });
    });

    group('checkAuthStatus', () {
      test('sets authenticated when token is valid', () async {
        // Arrange
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.isTokenExpired())
            .thenAnswer((_) async => false);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUserModel);

        // Act
        await viewModel.checkAuthStatus();

        // Assert
        viewModel.state.maybeWhen(
          authenticated: (authenticatedUser) {
            expect(authenticatedUser.email, 'test@example.com');
          },
          orElse: () => fail('Expected authenticated state'),
        );
      });

      test('sets unauthenticated when not authenticated', () async {
        // Arrange
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => false);

        // Act
        await viewModel.checkAuthStatus();

        // Assert
        viewModel.state.maybeWhen(
          unauthenticated: () => expect(true, true),
          orElse: () => fail('Expected unauthenticated state'),
        );
      });

      test('sets unauthenticated when token expired and refresh fails', () async {
        // Arrange
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.isTokenExpired())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.refreshToken())
            .thenAnswer((_) async => false);

        // Act
        await viewModel.checkAuthStatus();

        // Assert
        viewModel.state.maybeWhen(
          unauthenticated: () => expect(true, true),
          orElse: () => fail('Expected unauthenticated state'),
        );
      });

      test('sets error state when network exception occurs', () async {
        // Arrange
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.isTokenExpired())
            .thenAnswer((_) async => false);
        when(() => mockAuthRepository.getCurrentUser())
            .thenThrow(NetworkException(message: 'Connection failed'));

        // Act
        await viewModel.checkAuthStatus();

        // Assert
        viewModel.state.maybeWhen(
          error: (message, _) {
            expect(message, contains('Unable to reach server'));
          },
          orElse: () => fail('Expected error state on network error'),
        );
      });

      test('sets error state when timeout exception occurs', () async {
        // Arrange
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.isTokenExpired())
            .thenAnswer((_) async => false);
        when(() => mockAuthRepository.getCurrentUser())
            .thenThrow(TimeoutException(message: 'Connection timed out'));

        // Act
        await viewModel.checkAuthStatus();

        // Assert
        viewModel.state.maybeWhen(
          error: (message, _) {
            expect(message, contains('Connection timed out'));
          },
          orElse: () => fail('Expected error state on timeout'),
        );
      });
    });

    group('clearError', () {
      test('clears error state to unauthenticated', () async {
        // Set error state first
        when(() => mockAuthRepository.login(any(), any()))
            .thenThrow(Exception('Error'));
        await viewModel.login('test', 'test');

        // Act
        viewModel.clearError();

        // Assert
        viewModel.state.maybeWhen(
          unauthenticated: () => expect(true, true),
          orElse: () => fail('Expected unauthenticated state'),
        );
      });
    });

    group('currentUser', () {
      test('returns null when not authenticated', () {
        expect(viewModel.currentUser, null);
      });

      test('returns user when authenticated', () async {
        const userSummary = AccountSummary(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
        );

        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => userSummary);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUserModel);

        await viewModel.login('test@example.com', 'password');

        expect(viewModel.currentUser?.email, 'test@example.com');
      });
    });
  });
}
