import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/workout_execution_models.dart';
import '../services/workout_execution_service.dart';

/// Provider for WorkoutExecutionRepository
final workoutExecutionRepositoryProvider =
    Provider<WorkoutExecutionRepository>((ref) {
  final service = ref.watch(workoutExecutionServiceProvider);
  return WorkoutExecutionRepository(service: service);
});

/// Repository for workout execution operations
/// Orchestrates between API service and handles error unwrapping
class WorkoutExecutionRepository {
  final WorkoutExecutionService _service;

  WorkoutExecutionRepository({required WorkoutExecutionService service})
      : _service = service;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw WorkoutExecutionException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw WorkoutExecutionException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Unwrap ApiResponse for void operations
  void _unwrapVoidResponse(ApiResponse<void> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw WorkoutExecutionException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
  }

  /// UC-5.1: Start a workout session
  Future<WorkoutProgressResponse> startWorkout(
      StartWorkoutRequest request) async {
    final response = await _service.startWorkout(request);
    return _unwrapResponse(response);
  }

  /// UC-5.2: Log exercise performance
  Future<WorkoutProgressResponse> logExercise(
      int progressId, LogExerciseRequest request) async {
    final response = await _service.logExercise(progressId, request);
    return _unwrapResponse(response);
  }

  /// UC-5.3: Complete workout session
  Future<WorkoutProgressResponse> completeWorkout(
      int progressId, CompleteWorkoutRequest request) async {
    final response = await _service.completeWorkout(progressId, request);
    return _unwrapResponse(response);
  }

  /// UC-5.4: Skip an exercise during workout
  Future<WorkoutProgressResponse> skipExercise(
      int progressId, SkipExerciseRequest request) async {
    final response = await _service.skipExercise(progressId, request);
    return _unwrapResponse(response);
  }

  /// UC-5.5: Get workout history (paginated)
  Future<PageData<WorkoutHistoryResponse>> getWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
    String sort = 'workoutDate,desc',
  }) async {
    final response = await _service.getWorkoutHistory(
      startDate: startDate,
      endDate: endDate,
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// UC-5.6: Get progress charts
  Future<ProgressChartResponse> getProgressCharts({
    DateTime? startDate,
    DateTime? endDate,
    String? exerciseId,
  }) async {
    final response = await _service.getProgressCharts(
      startDate: startDate,
      endDate: endDate,
      exerciseId: exerciseId,
    );
    return _unwrapResponse(response);
  }

  /// Get weekly workout progress
  Future<WeeklyWorkoutProgressResponse> getWeeklyProgress({
    DateTime? startDate,
  }) async {
    final response = await _service.getWeeklyProgress(startDate: startDate);
    return _unwrapResponse(response);
  }

  /// Get current in-progress workout (returns null if none)
  Future<WorkoutProgressResponse?> getCurrentWorkout() async {
    final response = await _service.getCurrentWorkout();
    if (!response.success) return null;
    return response.data;
  }

  /// Get workout details by ID
  Future<WorkoutProgressResponse> getWorkoutById(int progressId) async {
    final response = await _service.getWorkoutById(progressId);
    return _unwrapResponse(response);
  }

  /// Cancel/abandon an in-progress workout
  Future<void> cancelWorkout(int progressId) async {
    final response = await _service.cancelWorkout(progressId);
    _unwrapVoidResponse(response);
  }
}

/// Custom exception for workout execution operations
class WorkoutExecutionException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  WorkoutExecutionException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
