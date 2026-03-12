import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../models/home_models.dart';
import '../models/home_dashboard_models.dart';
import '../services/home_service.dart';

/// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final service = ref.watch(homeServiceProvider);
  return HomeRepository(service: service);
});

/// Repository for home dashboard operations
class HomeRepository {
  final HomeService _service;

  HomeRepository({required HomeService service}) : _service = service;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw HomeException(message: errorMessage);
    }
    if (response.data == null) {
      throw HomeException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Get aggregated home dashboard data
  Future<HomeDashboardResponse> getDashboard({String? date}) async {
    final response = await _service.getDashboard(date: date);
    return _unwrapResponse(response);
  }

  /// Get weekly workout progress
  Future<WeeklyWorkoutProgressResponse> getWeeklyProgress({
    String? startDate,
  }) async {
    final response = await _service.getWeeklyProgress(startDate: startDate);
    return _unwrapResponse(response);
  }

  /// Get progress charts
  Future<ProgressChartResponse> getProgressCharts({
    String? startDate,
    String? endDate,
    String? exerciseId,
  }) async {
    final response = await _service.getProgressCharts(
      startDate: startDate,
      endDate: endDate,
      exerciseId: exerciseId,
    );
    return _unwrapResponse(response);
  }
}

/// Custom exception for home operations
class HomeException implements Exception {
  final String message;

  HomeException({required this.message});

  @override
  String toString() => message;
}
