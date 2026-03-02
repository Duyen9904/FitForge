import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/home_models.dart';
import '../models/home_dashboard_models.dart';

/// Provider for HomeService
final homeServiceProvider = Provider<HomeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeService(apiClient: apiClient);
});

/// Service for home dashboard API operations
class HomeService {
  final ApiClient apiClient;

  HomeService({required this.apiClient});

  /// Get aggregated home dashboard data
  Future<ApiResponse<HomeDashboardResponse>> getDashboard({
    String? date,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;

    final response = await apiClient.get(
      ApiConstants.workoutDashboard,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => HomeDashboardResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get weekly workout progress for the bar chart
  Future<ApiResponse<WeeklyWorkoutProgressResponse>> getWeeklyProgress({
    String? startDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate;

    final response = await apiClient.get(
      ApiConstants.workoutWeeklyProgress,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WeeklyWorkoutProgressResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  /// Get progress charts data
  Future<ApiResponse<ProgressChartResponse>> getProgressCharts({
    String? startDate,
    String? endDate,
    int? exerciseId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (exerciseId != null) queryParams['exerciseId'] = exerciseId;

    final response = await apiClient.get(
      ApiConstants.workoutProgressCharts,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          ProgressChartResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
