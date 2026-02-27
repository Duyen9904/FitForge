import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../models/in_body_models.dart';
import '../models/measurement_goal_models.dart';
import '../models/measurement_models.dart';
import '../models/progress_photo_models.dart';
import '../services/measurement_service.dart';

/// Provider for MeasurementRepository
final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final measurementService = ref.watch(measurementServiceProvider);
  return MeasurementRepository(measurementService: measurementService);
});

/// Repository for measurement data. Unwraps ApiResponse and throws on failure.
class MeasurementRepository {
  final MeasurementService _measurementService;

  MeasurementRepository({required MeasurementService measurementService})
      : _measurementService = measurementService;

  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage = response.error?.message ??
          response.message ??
          'Request failed';
      throw MeasurementException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw MeasurementException(message: 'No data in response');
    }
    return response.data as T;
  }

  void _unwrapVoidResponse(ApiResponse<void> response) {
    if (!response.success) {
      final errorMessage = response.error?.message ??
          response.message ??
          'Request failed';
      throw MeasurementException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
  }

  Future<MeasurementResponse> recordMeasurement(
    RecordMeasurementRequest request,
  ) async {
    final response = await _measurementService.recordMeasurement(request);
    return _unwrapResponse(response);
  }

  Future<MeasurementResponse> getLatestMeasurement() async {
    final response = await _measurementService.getLatestMeasurement();
    return _unwrapResponse(response);
  }

  Future<MeasurementResponse> getMeasurementById(int measurementId) async {
    final response =
        await _measurementService.getMeasurementById(measurementId);
    return _unwrapResponse(response);
  }

  Future<MeasurementHistoryResponse> getMeasurementHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _measurementService.getMeasurementHistory(
      startDate: startDate,
      endDate: endDate,
    );
    return _unwrapResponse(response);
  }

  Future<MeasurementResponse> importInBodyReport(File file) async {
    final response = await _measurementService.importInBodyReport(file);
    return _unwrapResponse(response);
  }

  Future<MeasurementResponse> importInBodyManual(
    InBodyImportRequest request,
  ) async {
    final response = await _measurementService.importInBodyManual(request);
    return _unwrapResponse(response);
  }

  Future<MeasurementGoalResponse> setMeasurementGoal(
    SetMeasurementGoalRequest request,
  ) async {
    final response = await _measurementService.setMeasurementGoal(request);
    return _unwrapResponse(response);
  }

  Future<MeasurementGoalResponse> getMeasurementGoal() async {
    final response = await _measurementService.getMeasurementGoal();
    return _unwrapResponse(response);
  }

  Future<ProgressPhotoResponse> uploadProgressPhoto(
    File file,
    UploadProgressPhotoRequest request,
  ) async {
    final response =
        await _measurementService.uploadProgressPhoto(file, request);
    return _unwrapResponse(response);
  }

  Future<List<ProgressPhotoResponse>> getProgressPhotos({
    String? category,
  }) async {
    final response =
        await _measurementService.getProgressPhotos(category: category);
    return _unwrapResponse(response);
  }

  Future<void> deleteProgressPhoto(int photoId) async {
    final response = await _measurementService.deleteProgressPhoto(photoId);
    _unwrapVoidResponse(response);
  }
}

/// Exception for measurement operations with optional field-level errors.
class MeasurementException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  MeasurementException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
