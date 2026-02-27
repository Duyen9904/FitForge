import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response wrapper
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? message,
    ApiError? error,
    PaginationMeta? pagination,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

@freezed
class ApiError with _$ApiError {
  const factory ApiError({
    required String code,
    required String message,
    Map<String, List<String>>? fieldErrors,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) => 
      _$ApiErrorFromJson(json);
}

@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    @Default(false) bool first,
    @Default(false) bool last,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => 
      _$PaginationMetaFromJson(json);
}
