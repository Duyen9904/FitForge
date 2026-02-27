import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthService service;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    service = AuthService(apiClient: mockApiClient);
  });

  group('AuthService', () {
    group('login', () {
      test('returns successful ApiResponse on valid login', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'accessToken': 'access_token',
            'refreshToken': 'refresh_token',
            'tokenType': 'Bearer',
            'expiresAt': 1700000000000,
            'user': {
              'id': 1,
              'username': 'testuser',
              'email': 'test@example.com',
            },
          },
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.login('test@example.com', 'password123');

        // Assert
        expect(result.success, true);
        expect(result.data?.accessToken, 'access_token');
        expect(result.data?.refreshToken, 'refresh_token');
        expect(result.data?.user?.email, 'test@example.com');
      });

      test('returns unsuccessful ApiResponse on invalid login', () async {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Invalid credentials',
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.login('test@example.com', 'wrongpassword');

        // Assert
        expect(result.success, false);
        expect(result.message, 'Invalid credentials');
        expect(result.data, null);
      });

      test('returns ApiResponse with field errors on validation failure', () async {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Validation failed',
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid input',
            'fieldErrors': {
              'email': ['Email is required'],
              'password': ['Password must be at least 8 characters'],
            },
          },
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.login('', 'short');

        // Assert
        expect(result.success, false);
        expect(result.error?.fieldErrors?['email'], ['Email is required']);
        expect(result.error?.fieldErrors?['password'], ['Password must be at least 8 characters']);
      });
    });

    group('register', () {
      test('returns successful ApiResponse on valid registration', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Registration successful',
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.register(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        );

        // Assert
        expect(result.success, true);
        expect(result.message, 'Registration successful');
      });

      test('returns unsuccessful ApiResponse on failed registration', () async {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Email already exists',
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.register(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        );

        // Assert
        expect(result.success, false);
        expect(result.message, 'Email already exists');
      });
    });

    group('refreshToken', () {
      test('returns successful ApiResponse on valid refresh', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'accessToken': 'new_access',
            'refreshToken': 'new_refresh',
            'tokenType': 'Bearer',
            'expiresAt': 1700000000000,
          },
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.refreshToken('old_refresh');

        // Assert
        expect(result.success, true);
        expect(result.data?.accessToken, 'new_access');
        expect(result.data?.refreshToken, 'new_refresh');
      });

      test('returns unsuccessful ApiResponse on invalid refresh', () async {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Token expired',
        };

        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: responseData,
                ));

        // Act
        final result = await service.refreshToken('invalid_refresh');

        // Assert
        expect(result.success, false);
        expect(result.message, 'Token expired');
      });
    });

    group('logout', () {
      test('returns successful ApiResponse on logout', () async {
        // Arrange
        when(() => mockApiClient.post(any(), queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: {'success': true},
                ));

        // Act
        final result = await service.logout('test@example.com');

        // Assert
        expect(result.success, true);
        verify(() => mockApiClient.post(any(), queryParameters: {'email': 'test@example.com'}))
            .called(1);
      });
    });
  });
}
