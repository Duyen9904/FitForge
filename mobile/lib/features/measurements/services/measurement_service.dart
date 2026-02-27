import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/in_body_models.dart';
import '../models/measurement_goal_models.dart';
import '../models/measurement_models.dart';
import '../models/progress_photo_models.dart';

/// Provider for MeasurementService
final measurementServiceProvider = Provider<MeasurementService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MeasurementService(apiClient: apiClient);
});

/// Service for measurement API operations.
/// All methods return ApiResponse<T>. Multipart uses apiClient.dio.
class MeasurementService {
  final ApiClient apiClient;

  MeasurementService({required this.apiClient});

  /// UC-8.1: Record body measurement
  Future<ApiResponse<MeasurementResponse>> recordMeasurement(
    RecordMeasurementRequest request,
  ) async {
    final response = await apiClient.post(
      ApiConstants.measurements,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MeasurementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get the most recent measurement record
  Future<ApiResponse<MeasurementResponse>> getLatestMeasurement() async {
    final response = await apiClient.get(ApiConstants.measurementsLatest);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MeasurementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get a specific measurement record by ID
  Future<ApiResponse<MeasurementResponse>> getMeasurementById(
    int measurementId,
  ) async {
    final response = await apiClient.get(
      ApiConstants.measurementById(measurementId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MeasurementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.2: Get measurement history with optional date range
  Future<ApiResponse<MeasurementHistoryResponse>> getMeasurementHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = _toIsoDate(startDate);
    }
    if (endDate != null) {
      queryParams['endDate'] = _toIsoDate(endDate);
    }

    final response = await apiClient.get(
      ApiConstants.measurements,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MeasurementHistoryResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.5: Import InBody report via OCR (multipart)
  Future<ApiResponse<MeasurementResponse>> importInBodyReport(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final response = await apiClient.dio.post<Map<String, dynamic>>(
      ApiConstants.measurementsImportInbody,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    return _parseResponse(
      response.data,
      (json) => MeasurementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.5: Manually import InBody data
  Future<ApiResponse<MeasurementResponse>> importInBodyManual(
    InBodyImportRequest request,
  ) async {
    final response = await apiClient.post(
      ApiConstants.measurementsImportInbodyManual,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MeasurementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.3: Set measurement goal
  Future<ApiResponse<MeasurementGoalResponse>> setMeasurementGoal(
    SetMeasurementGoalRequest request,
  ) async {
    final response = await apiClient.post(
      ApiConstants.measurementsGoals,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MeasurementGoalResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get current measurement goal
  Future<ApiResponse<MeasurementGoalResponse>> getMeasurementGoal() async {
    final response = await apiClient.get(ApiConstants.measurementsGoals);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MeasurementGoalResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.4: Upload progress photo (multipart: file + data)
  Future<ApiResponse<ProgressPhotoResponse>> uploadProgressPhoto(
    File file,
    UploadProgressPhotoRequest request,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'data': MultipartFile.fromString(
        jsonEncode(request.toJson()),
        filename: 'data.json',
      ),
    });

    final response = await apiClient.dio.post<Map<String, dynamic>>(
      ApiConstants.measurementsPhotos,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    return _parseResponse(
      response.data,
      (json) =>
          ProgressPhotoResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-8.4: Get progress photos, optionally by category
  Future<ApiResponse<List<ProgressPhotoResponse>>> getProgressPhotos({
    String? category,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await apiClient.get(
      ApiConstants.measurementsPhotos,
      queryParameters:
          queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((e) =>
                ProgressPhotoResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Delete a progress photo (204 or JSON body)
  Future<ApiResponse<void>> deleteProgressPhoto(int photoId) async {
    final response = await apiClient.delete(
      ApiConstants.measurementPhotoById(photoId),
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      return const ApiResponse(success: true, data: null);
    }
    return ApiResponse.fromJson(data, (_) {});
  }

  String _toIsoDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  ApiResponse<T> _parseResponse<T>(
    Map<String, dynamic>? raw,
    T Function(Object? json) fromJsonT,
  ) {
    if (raw == null) {
      return const ApiResponse(success: false, data: null);
    }
    return ApiResponse.fromJson(raw, fromJsonT);
  }
}
