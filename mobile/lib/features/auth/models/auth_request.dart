import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request.freezed.dart';
part 'auth_request.g.dart';

/// Login request DTO - matches backend LoginRequestDto
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestFromJson(json);
}

/// Register request DTO - matches backend RegisterRequestDto
/// Only contains core account fields. Profile data is collected during onboarding.
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => 
      _$RegisterRequestFromJson(json);
}

/// Refresh token request DTO - matches backend RefreshTokenRequest
@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => 
      _$RefreshTokenRequestFromJson(json);
}

/// Google auth request DTO
@freezed
class GoogleAuthRequest with _$GoogleAuthRequest {
  const factory GoogleAuthRequest({
    required String googleToken,
  }) = _GoogleAuthRequest;

  factory GoogleAuthRequest.fromJson(Map<String, dynamic> json) => 
      _$GoogleAuthRequestFromJson(json);
}
