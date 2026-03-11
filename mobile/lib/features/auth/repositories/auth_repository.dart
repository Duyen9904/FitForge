import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../notifications/repositories/notification_repository.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final localStorage = ref.watch(localStorageProvider);
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return AuthRepository(
    authService: authService,
    secureStorage: secureStorage,
    localStorage: localStorage,
    notificationRepository: notificationRepository,
  );
});

/// Repository pattern - source of truth for auth data
/// Orchestrates between API service and local storage
class AuthRepository {
  final AuthService _authService;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;
  final NotificationRepository _notificationRepository;

  AuthRepository({
    required AuthService authService,
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
    required NotificationRepository notificationRepository,
  })  : _authService = authService,
        _secureStorage = secureStorage,
        _localStorage = localStorage,
        _notificationRepository = notificationRepository;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage = response.error?.message ?? 
                           response.message ?? 
                           'Request failed';
      throw AuthException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw AuthException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Unwrap ApiResponse for void operations
  void _unwrapVoidResponse(ApiResponse<void> response) {
    if (!response.success) {
      final errorMessage = response.error?.message ?? 
                           response.message ?? 
                           'Request failed';
      throw AuthException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
  }

  /// Login with email and password
  /// Returns AccountSummary on success
  Future<AccountSummary> login(String email, String password) async {
    final response = await _authService.login(email, password);
    final authResponse = _unwrapResponse(response);
    await _saveTokens(authResponse);

    // Register device for push notifications after successful login
    _initPushNotifications();

    return authResponse.user!;
  }

  /// Login with Google token
  Future<AccountSummary> loginWithGoogle(String googleToken) async {
    final response = await _authService.loginWithGoogle(googleToken);
    final authResponse = _unwrapResponse(response);
    await _saveTokens(authResponse);

    // Register device for push notifications after successful login
    _initPushNotifications();

    return authResponse.user!;
  }

  /// Register a new user
  /// Only requires core account fields. Profile data is collected during onboarding.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _authService.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    _unwrapVoidResponse(response);
  }

  /// Register with Google token
  Future<void> registerWithGoogle(String googleToken) async {
    final response = await _authService.registerWithGoogle(googleToken);
    _unwrapVoidResponse(response);
  }

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    final response = await _authService.getCurrentUser();
    return _unwrapResponse(response);
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _authService.refreshToken(refreshToken);
      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Logout
  Future<void> logout(String email) async {
    try {
      // Unregister device from push notifications before logout
      await _notificationRepository.unregisterDevice();
    } catch (e) {
      developer.log('Failed to unregister device on logout: $e', name: 'AUTH');
    }

    try {
      await _authService.logout(email);
    } finally {
      await _secureStorage.clearTokens();
      // Clear onboarding cache on logout
      await _localStorage.remove(StorageKeys.onboardingCompleted);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await _secureStorage.getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(AuthResponse authResponse) async {
    await _secureStorage.saveAccessToken(authResponse.accessToken);
    await _secureStorage.saveRefreshToken(authResponse.refreshToken);
    if (authResponse.expiresAt != null) {
      await _secureStorage.saveTokenExpiry(authResponse.expiresAt!);
    }
  }

  /// Fire-and-forget push notification init
  void _initPushNotifications() {
    _notificationRepository.initializePushNotifications().catchError((e) {
      developer.log('Push notification init failed: $e', name: 'AUTH');
    });
  }
}

/// Custom exception for auth operations with field-level errors support
class AuthException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  AuthException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
