import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/models/auth_response.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockSecureStorage extends Mock implements SecureStorage {}
class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late AuthRepository repository;
  late MockAuthService mockAuthService;
  late MockSecureStorage mockSecureStorage;
  late MockLocalStorage mockLocalStorage;

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorage = MockSecureStorage();
    mockLocalStorage = MockLocalStorage();
    repository = AuthRepository(
      authService: mockAuthService,
      secureStorage: mockSecureStorage,
      localStorage: mockLocalStorage,
    );
  });

  group('AuthRepository', () {
    group('login', () {
      test('saves tokens and returns user on successful login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final authResponse = AuthResponse(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
          user: const AccountSummary(
            id: 1,
            username: 'testuser',
            email: 'test@example.com',
          ),
        );

        when(() => mockAuthService.login(email, password))
            .thenAnswer((_) async => ApiResponse(
              success: true,
              data: authResponse,
            ));
        when(() => mockSecureStorage.saveAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.saveRefreshToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.saveTokenExpiry(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.email, email);
        expect(result.username, 'testuser');
        verify(() => mockSecureStorage.saveAccessToken('access_token')).called(1);
        verify(() => mockSecureStorage.saveRefreshToken('refresh_token')).called(1);
        verify(() => mockSecureStorage.saveTokenExpiry(any())).called(1);
      });
    });

    group('logout', () {
      test('clears tokens after logout', () async {
        // Arrange
        const email = 'test@example.com';
        when(() => mockAuthService.logout(email))
            .thenAnswer((_) async => const ApiResponse(
              success: true,
            ));
        when(() => mockSecureStorage.clearTokens()).thenAnswer((_) async {});
        when(() => mockLocalStorage.remove(StorageKeys.onboardingCompleted))
            .thenAnswer((_) async => true);

        // Act
        await repository.logout(email);

        // Assert
        verify(() => mockSecureStorage.clearTokens()).called(1);
      });
    });

    group('isAuthenticated', () {
      test('returns true when token exists', () async {
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => 'token');

        final result = await repository.isAuthenticated();

        expect(result, true);
      });

      test('returns false when token is null', () async {
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => null);

        final result = await repository.isAuthenticated();

        expect(result, false);
      });

      test('returns false when token is empty', () async {
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => '');

        final result = await repository.isAuthenticated();

        expect(result, false);
      });
    });

    group('isTokenExpired', () {
      test('returns true when expiry is null', () async {
        when(() => mockSecureStorage.getTokenExpiry())
            .thenAnswer((_) async => null);

        final result = await repository.isTokenExpired();

        expect(result, true);
      });

      test('returns true when expiry is in the past', () async {
        when(() => mockSecureStorage.getTokenExpiry())
            .thenAnswer((_) async => DateTime(2020, 1, 1));

        final result = await repository.isTokenExpired();

        expect(result, true);
      });

      test('returns false when expiry is in the future', () async {
        when(() => mockSecureStorage.getTokenExpiry())
            .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

        final result = await repository.isTokenExpired();

        expect(result, false);
      });
    });

    group('refreshToken', () {
      test('returns true and saves new tokens on success', () async {
        // Arrange
        final authResponse = AuthResponse(
          accessToken: 'new_access',
          refreshToken: 'new_refresh',
          expiresAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        );

        when(() => mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => 'old_refresh');
        when(() => mockAuthService.refreshToken('old_refresh'))
            .thenAnswer((_) async => ApiResponse(
              success: true,
              data: authResponse,
            ));
        when(() => mockSecureStorage.saveAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.saveRefreshToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.saveTokenExpiry(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.refreshToken();

        // Assert
        expect(result, true);
        verify(() => mockSecureStorage.saveAccessToken('new_access')).called(1);
        verify(() => mockSecureStorage.saveRefreshToken('new_refresh')).called(1);
      });

      test('returns false when no refresh token', () async {
        when(() => mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        final result = await repository.refreshToken();

        expect(result, false);
      });
    });

    group('getCurrentUser', () {
      test('returns user from service', () async {
        const user = UserModel(
          userId: 1,
          username: 'testuser',
          email: 'test@example.com',
        );

        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async => const ApiResponse(
              success: true,
              data: user,
            ));

        final result = await repository.getCurrentUser();

        expect(result.email, 'test@example.com');
      });
    });
  });
}
