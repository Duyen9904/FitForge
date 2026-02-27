import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/exercise_filter.dart';
import '../models/exercise_models.dart';
import '../models/exercise_category_response.dart';
import '../models/exercise_type_response.dart';

/// Provider for ExerciseService
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExerciseService(apiClient: apiClient);
});

/// Service for exercise API operations
/// All methods return ApiResponse<T> to preserve error details
class ExerciseService {
  final ApiClient apiClient;

  ExerciseService({required this.apiClient});

  /// Get all available exercise types with counts
  Future<ApiResponse<List<ExerciseTypeResponse>>> getExerciseTypes() async {
    final response = await apiClient.get(ApiConstants.exerciseTypes);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) =>
                ExerciseTypeResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get exercise categories (muscle groups) with exercise counts
  Future<ApiResponse<List<ExerciseCategoryResponse>>> getExerciseCategories() async {
    final response = await apiClient.get(ApiConstants.exerciseCategories);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) =>
                ExerciseCategoryResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// UC-4.1: Browse exercises with filters and pagination
  Future<ApiResponse<PageData<ExerciseSummary>>> browseExercises({
    ExerciseFilter? filter,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (sort != null) 'sort': sort,
      ...?filter?.toQueryParams(),
    };

    final response = await apiClient.get(
      ApiConstants.exercises,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<ExerciseSummary>.fromJson(
        json as Map<String, dynamic>,
        (item) => ExerciseSummary.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  /// UC-4.2: Get exercise details by ID
  Future<ApiResponse<Exercise>> getExerciseById(int exerciseId) async {
    final response = await apiClient.get(
      ApiConstants.exerciseDetail(exerciseId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Exercise.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-4.3: Add exercise to favorites
  Future<ApiResponse<void>> addToFavorites(int exerciseId) async {
    final response = await apiClient.post(
      ApiConstants.exerciseAddFavorite(exerciseId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// UC-4.3: Remove exercise from favorites
  Future<ApiResponse<void>> removeFromFavorites(int exerciseId) async {
    final response = await apiClient.delete(
      ApiConstants.exerciseRemoveFavorite(exerciseId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// UC-4.3: Check if exercise is in favorites
  Future<ApiResponse<bool>> isFavorite(int exerciseId) async {
    final response = await apiClient.get(
      ApiConstants.exerciseIsFavorite(exerciseId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json as bool,
    );
  }

  /// UC-4.3: Get user's favorite exercises
  Future<ApiResponse<PageData<ExerciseSummary>>> getUserFavorites({
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = {
      'page': page,
      'size': size,
    };

    final response = await apiClient.get(
      ApiConstants.exerciseFavorites,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<ExerciseSummary>.fromJson(
        json as Map<String, dynamic>,
        (item) => ExerciseSummary.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  /// UC-4.4: Get alternative exercises
  Future<ApiResponse<List<ExerciseAlternative>>> getAlternatives(
      int exerciseId) async {
    final response = await apiClient.get(
      ApiConstants.exerciseAlternatives(exerciseId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) =>
                ExerciseAlternative.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// UC-12.3: Get exercise recommendations
  Future<ApiResponse<List<ExerciseRecommendation>>> getRecommendations({
    int? sessionId,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (sessionId != null) 'sessionId': sessionId,
    };

    final response = await apiClient.get(
      ApiConstants.exerciseRecommendations,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) =>
                ExerciseRecommendation.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
