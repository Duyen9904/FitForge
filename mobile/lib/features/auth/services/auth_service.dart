import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});

/// Service for authentication API operations only
/// Storage is handled by AuthRepository
/// All methods return ApiResponse<T> to preserve error details
class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  /// Login with email and password
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Login with Google token
  Future<ApiResponse<AuthResponse>> loginWithGoogle(String googleToken) async {
    final response = await apiClient.post(
      ApiConstants.loginGoogle,
      queryParameters: {'googleToken': googleToken},
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Register a new user
  /// Only requires core account fields. Profile data is collected during onboarding.
  Future<ApiResponse<void>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: RegisterRequest(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ).toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// Register with Google token
  Future<ApiResponse<void>> registerWithGoogle(String googleToken) async {
    final response = await apiClient.post(
      ApiConstants.registerGoogle,
      queryParameters: {'googleToken': googleToken},
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.currentUser);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Refresh access token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshToken,
      data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Logout - requires email as per backend
  Future<ApiResponse<void>> logout(String email) async {
    final response = await apiClient.post(
      ApiConstants.logout,
      queryParameters: {'email': email},
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }
}

