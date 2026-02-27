import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../storage/secure_storage.dart';
import '../../constants/api_constants.dart';

/// Interceptor for adding authentication headers and handling token refresh
class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    final noAuthPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refreshToken,
    ];

    if (!noAuthPaths.any((path) => options.path.contains(path))) {
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - Try to refresh token
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          debugPrint('AuthInterceptor: 401 received, attempting token refresh...');

          // Use a fresh Dio with proper config (no interceptors to avoid loops)
          final dio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));

          final response = await dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            // Backend wraps in ApiResponse: { success, data: { accessToken, refreshToken, ... }, message }
            final responseData = response.data;
            final data = responseData['data'];

            if (data == null) {
              debugPrint('AuthInterceptor: Refresh response missing data field');
              await secureStorage.clearTokens();
              return handler.next(err);
            }

            final newAccessToken = data['accessToken'];
            final newRefreshToken = data['refreshToken'];

            debugPrint('AuthInterceptor: Token refresh successful');

            // Save new tokens
            await secureStorage.saveAccessToken(newAccessToken);
            if (newRefreshToken != null) {
              await secureStorage.saveRefreshToken(newRefreshToken);
            }

            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          debugPrint('AuthInterceptor: Token refresh failed: $e');
          // Refresh failed - clear tokens
          await secureStorage.clearTokens();
        }
      }
    }

    handler.next(err);
  }
}
