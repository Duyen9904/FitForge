import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/missed_workout_models.dart';
import '../services/missed_workout_service.dart';

/// Provider for MissedWorkoutRepository
final missedWorkoutRepositoryProvider =
    Provider<MissedWorkoutRepository>((ref) {
  final service = ref.watch(missedWorkoutServiceProvider);
  return MissedWorkoutRepository(service: service);
});

/// Repository for missed workout operations.
/// Orchestrates between API service and handles error unwrapping.
class MissedWorkoutRepository {
  final MissedWorkoutService _service;

  MissedWorkoutRepository({required MissedWorkoutService service})
      : _service = service;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw MissedWorkoutException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw MissedWorkoutException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Get missed workouts (paginated)
  Future<PageData<MissedWorkoutResponse>> getMissedWorkouts({
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) async {
    final response = await _service.getMissedWorkouts(
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// Get unaddressed missed workouts
  Future<List<MissedWorkoutResponse>> getUnaddressedMissedWorkouts() async {
    final response = await _service.getUnaddressedMissedWorkouts();
    return _unwrapResponse(response);
  }

  /// Get missed workout by ID
  Future<MissedWorkoutResponse> getMissedWorkout(int missedWorkoutId) async {
    final response = await _service.getMissedWorkout(missedWorkoutId);
    return _unwrapResponse(response);
  }

  /// UC-6.2: Get makeup options
  Future<List<MakeupWorkoutOptionResponse>> getMakeupOptions(
      int missedWorkoutId) async {
    final response = await _service.getMakeupOptions(missedWorkoutId);
    return _unwrapResponse(response);
  }

  /// UC-6.2: Select and apply makeup option
  Future<MissedWorkoutResponse> selectMakeupOption(
      int missedWorkoutId, SelectMakeupOptionRequest request) async {
    final response =
        await _service.selectMakeupOption(missedWorkoutId, request);
    return _unwrapResponse(response);
  }

  /// UC-6.3: Reschedule missed workout
  Future<MissedWorkoutResponse> rescheduleMissedWorkout(
      int missedWorkoutId, RescheduleMissedWorkoutRequest request) async {
    final response =
        await _service.rescheduleMissedWorkout(missedWorkoutId, request);
    return _unwrapResponse(response);
  }

  /// Get active makeup workouts
  Future<List<MakeupWorkoutResponse>> getActiveMakeupWorkouts() async {
    final response = await _service.getActiveMakeupWorkouts();
    return _unwrapResponse(response);
  }

  /// UC-6.4: Get missed workout report
  Future<MissedWorkoutReportResponse> getMissedWorkoutReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _service.getMissedWorkoutReport(
      startDate: startDate,
      endDate: endDate,
    );
    return _unwrapResponse(response);
  }
}

/// Custom exception for missed workout operations
class MissedWorkoutException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  MissedWorkoutException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
