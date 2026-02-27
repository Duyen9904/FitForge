import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/date_utils.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Generic API response wrapper - matches backend ApiResponse<T>
@Freezed(genericArgumentFactories: true)
class ApiResponseWrapper<T> with _$ApiResponseWrapper<T> {
  const factory ApiResponseWrapper({
    required bool success,
    T? data,
    String? message,
  }) = _ApiResponseWrapper<T>;

  factory ApiResponseWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseWrapperFromJson(json, fromJsonT);
}

/// Auth response DTO - matches backend AuthResponseDto
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    @Default('Bearer') String tokenType,
    @JsonKey(fromJson: parseDateTime, toJson: dateTimeToEpochMs)
    DateTime? expiresAt,
    AccountSummary? user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);
}

/// Account summary for minimal user info - matches backend AccountSummaryDto
@freezed
class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    int? id,
    required String username,
    required String email,
    String? profileImageUrl,
  }) = _AccountSummary;

  factory AccountSummary.fromJson(Map<String, dynamic> json) => 
      _$AccountSummaryFromJson(json);
}

/// Token-only response for refresh endpoint
@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    required String accessToken,
    required String refreshToken,
    @Default('Bearer') String tokenType,
    int? expiresAt,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) => 
      _$TokenResponseFromJson(json);
}
