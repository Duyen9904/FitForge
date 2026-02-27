import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/recommendation_models.dart';

/// Provider for RecommendationService
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecommendationService(apiClient: apiClient);
});

/// Service for recommendation API operations
/// All methods return ApiResponse<T> to preserve error details
class RecommendationService {
  final ApiClient apiClient;

  RecommendationService({required this.apiClient});

  // ========== Workout Recommendations ==========

  /// Generate initial workout plan based on onboarding profile
  Future<ApiResponse<WorkoutPlanResponse>> generateWorkoutPlan(String startDate) async {
    final response = await apiClient.post(
      ApiConstants.recommendationsWorkoutGenerate,
      data: {'startDate': startDate},
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Adjust workout plan based on behavior (adherence, RPE, pain flags)
  Future<ApiResponse<WorkoutPlanResponse>> adjustWorkoutPlan(int planId) async {
    final response = await apiClient.post(
      ApiConstants.recommendationsWorkoutAdjust(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get or generate workout session for specific day
  Future<ApiResponse<WorkoutSessionResponse>> getWorkoutSessionForDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await apiClient.get(
      ApiConstants.recommendationsWorkoutSessionDay(planId, dayNumber),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ========== Nutrition Recommendations ==========

  /// Generate initial nutrition plan based on onboarding profile
  Future<ApiResponse<NutritionPlanResponse>> generateNutritionPlan() async {
    final response = await apiClient.post(
      ApiConstants.recommendationsNutritionGenerate,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Adjust nutrition plan based on behavior (adherence, calorie trends)
  Future<ApiResponse<NutritionPlanResponse>> adjustNutritionPlan(int planId) async {
    final response = await apiClient.post(
      ApiConstants.recommendationsNutritionAdjust(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get or generate meals for specific day
  Future<ApiResponse<List<MealTemplateResponse>>> getMealsForDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await apiClient.get(
      ApiConstants.recommendationsNutritionMealsDay(planId, dayNumber),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => MealTemplateResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
