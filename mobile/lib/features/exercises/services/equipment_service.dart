import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/exercise_models.dart';

/// Provider for EquipmentService
final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EquipmentService(apiClient: apiClient);
});

/// Service for equipment API operations
/// All methods return ApiResponse<T> to preserve error details
class EquipmentService {
  final ApiClient apiClient;

  EquipmentService({required this.apiClient});

  /// Get all equipment
  Future<ApiResponse<List<Equipment>>> getAllEquipment() async {
    final response = await apiClient.get(ApiConstants.equipment);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => Equipment.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get equipment details by ID
  Future<ApiResponse<Equipment>> getEquipmentById(int equipmentId) async {
    final response = await apiClient.get(
      '${ApiConstants.equipment}/$equipmentId',
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Equipment.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get exercises by equipment
  Future<ApiResponse<PageData<ExerciseSummary>>> getExercisesByEquipment(
    int equipmentId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.equipment}/$equipmentId/exercises',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<ExerciseSummary>.fromJson(
        json as Map<String, dynamic>,
        (item) => ExerciseSummary.fromJson(item as Map<String, dynamic>),
      ),
    );
  }
}
