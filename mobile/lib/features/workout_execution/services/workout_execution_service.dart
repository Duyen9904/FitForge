import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/workout_execution_models.dart';

/// Provider for WorkoutExecutionService
final workoutExecutionServiceProvider = Provider<WorkoutExecutionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkoutExecutionService(apiClient: apiClient);
});

/// Service for workout execution API operations.
/// All methods return [ApiResponse] to preserve error details.
class WorkoutExecutionService {
  final ApiClient apiClient;

  WorkoutExecutionService({required this.apiClient});

  /// UC-5.1: Start a workout session
  Future<ApiResponse<WorkoutProgressResponse>> startWorkout(
      StartWorkoutRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutStart,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-5.2: Log exercise performance
  Future<ApiResponse<WorkoutProgressResponse>> logExercise(
      int progressId, LogExerciseRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutLog(progressId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-5.3: Complete workout session
  Future<ApiResponse<WorkoutProgressResponse>> completeWorkout(
      int progressId, CompleteWorkoutRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutComplete(progressId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-5.4: Skip an exercise during workout
  Future<ApiResponse<WorkoutProgressResponse>> skipExercise(
      int progressId, SkipExerciseRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutSkip(progressId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-5.5: Get workout history (paginated)
  Future<ApiResponse<PageData<WorkoutHistoryResponse>>> getWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
    String sort = 'workoutDate,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
      if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
    };

    final response = await apiClient.get(
      ApiConstants.workoutHistory,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<WorkoutHistoryResponse>.fromJson(
        json as Map<String, dynamic>,
        (item) => WorkoutHistoryResponse.fromJson(
            item as Map<String, dynamic>),
      ),
    );
  }

  /// UC-5.6: Get progress charts
  Future<ApiResponse<ProgressChartResponse>> getProgressCharts({
    DateTime? startDate,
    DateTime? endDate,
    int? exerciseId,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
      if (exerciseId != null) 'exerciseId': exerciseId,
    };

    final response = await apiClient.get(
      ApiConstants.workoutProgressCharts,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          ProgressChartResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get weekly workout progress
  Future<ApiResponse<WeeklyWorkoutProgressResponse>> getWeeklyProgress({
    DateTime? startDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null)
        'startDate':
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
    };

    final response = await apiClient.get(
      ApiConstants.workoutWeeklyProgress,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WeeklyWorkoutProgressResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  /// Get current in-progress workout
  Future<ApiResponse<WorkoutProgressResponse>> getCurrentWorkout() async {
    final response = await apiClient.get(
      ApiConstants.workoutCurrent,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get workout details by ID
  Future<ApiResponse<WorkoutProgressResponse>> getWorkoutById(
      int progressId) async {
    final response = await apiClient.get(
      ApiConstants.workoutById(progressId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Cancel/abandon an in-progress workout
  Future<ApiResponse<void>> cancelWorkout(int progressId) async {
    final response = await apiClient.delete(
      ApiConstants.workoutById(progressId),
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      return const ApiResponse(success: true, data: null);
    }
    return ApiResponse.fromJson(data, (_) {});
  }
}
