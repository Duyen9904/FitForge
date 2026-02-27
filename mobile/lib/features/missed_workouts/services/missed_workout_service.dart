import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/missed_workout_models.dart';

/// Provider for MissedWorkoutService
final missedWorkoutServiceProvider = Provider<MissedWorkoutService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MissedWorkoutService(apiClient: apiClient);
});

/// Service for missed workout API operations.
/// All methods return [ApiResponse] to preserve error details.
class MissedWorkoutService {
  final ApiClient apiClient;

  MissedWorkoutService({required this.apiClient});

  /// Get missed workouts (paginated)
  Future<ApiResponse<PageData<MissedWorkoutResponse>>> getMissedWorkouts({
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };

    final response = await apiClient.get(
      ApiConstants.missedWorkouts,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<MissedWorkoutResponse>.fromJson(
        json as Map<String, dynamic>,
        (item) => MissedWorkoutResponse.fromJson(
            item as Map<String, dynamic>),
      ),
    );
  }

  /// Get unaddressed missed workouts (without makeup plan)
  Future<ApiResponse<List<MissedWorkoutResponse>>>
      getUnaddressedMissedWorkouts() async {
    final response = await apiClient.get(
      ApiConstants.missedWorkoutsUnaddressed,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => MissedWorkoutResponse.fromJson(
                item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get missed workout by ID
  Future<ApiResponse<MissedWorkoutResponse>> getMissedWorkout(
      int missedWorkoutId) async {
    final response = await apiClient.get(
      ApiConstants.missedWorkoutById(missedWorkoutId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MissedWorkoutResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-6.2: Generate makeup options for a missed workout
  Future<ApiResponse<List<MakeupWorkoutOptionResponse>>> getMakeupOptions(
      int missedWorkoutId) async {
    final response = await apiClient.get(
      ApiConstants.missedWorkoutMakeupOptions(missedWorkoutId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => MakeupWorkoutOptionResponse.fromJson(
                item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// UC-6.2: Select and apply a makeup option
  Future<ApiResponse<MissedWorkoutResponse>> selectMakeupOption(
      int missedWorkoutId, SelectMakeupOptionRequest request) async {
    final response = await apiClient.post(
      ApiConstants.missedWorkoutMakeup(missedWorkoutId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MissedWorkoutResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-6.3: Reschedule a missed workout to a new date
  Future<ApiResponse<MissedWorkoutResponse>> rescheduleMissedWorkout(
      int missedWorkoutId, RescheduleMissedWorkoutRequest request) async {
    final response = await apiClient.put(
      ApiConstants.missedWorkoutReschedule(missedWorkoutId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          MissedWorkoutResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get active (scheduled, incomplete) makeup workouts
  Future<ApiResponse<List<MakeupWorkoutResponse>>>
      getActiveMakeupWorkouts() async {
    final response = await apiClient.get(
      ApiConstants.missedWorkoutsMakeupWorkouts,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => MakeupWorkoutResponse.fromJson(
                item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// UC-6.4: Get missed workout report with consistency metrics
  Future<ApiResponse<MissedWorkoutReportResponse>> getMissedWorkoutReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null)
        'startDate': startDate.toIso8601String().split('T').first,
      if (endDate != null)
        'endDate': endDate.toIso8601String().split('T').first,
    };

    final response = await apiClient.get(
      ApiConstants.missedWorkoutsReport,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MissedWorkoutReportResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }
}
