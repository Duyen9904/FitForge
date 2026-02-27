import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../models/recommendation_models.dart';
import '../services/recommendation_service.dart';

/// Provider for RecommendationRepository
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final service = ref.watch(recommendationServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return RecommendationRepository(
    service: service,
    localStorage: localStorage,
  );
});

/// Repository for recommendation operations
/// Orchestrates between API service and local storage
class RecommendationRepository {
  final RecommendationService _service;
  final LocalStorage _localStorage;

  static const String _activeWorkoutPlanKey = 'active_workout_plan_id';
  static const String _activeNutritionPlanKey = 'active_nutrition_plan_id';

  RecommendationRepository({
    required RecommendationService service,
    required LocalStorage localStorage,
  })  : _service = service,
        _localStorage = localStorage;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw RecommendationException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw RecommendationException(message: 'No data in response');
    }
    return response.data as T;
  }

  // ========== Workout Recommendations ==========

  /// Generate initial workout plan
  Future<WorkoutPlanResponse> generateWorkoutPlan(String startDate) async {
    final response = await _service.generateWorkoutPlan(startDate);
    final plan = _unwrapResponse(response);

    return plan;
  }

  /// Adjust workout plan based on behavior
  Future<WorkoutPlanResponse> adjustWorkoutPlan(int planId) async {
    final response = await _service.adjustWorkoutPlan(planId);
    return _unwrapResponse(response);
  }

  /// Get or generate workout session for specific day
  Future<WorkoutSessionResponse> getWorkoutSessionForDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await _service.getWorkoutSessionForDay(planId, dayNumber);
    return _unwrapResponse(response);
  }

  /// Get cached active workout plan ID
  Future<int?> getActiveWorkoutPlanId() async {
    return await _localStorage.getInt(_activeWorkoutPlanKey);
  }

  // ========== Nutrition Recommendations ==========

  /// Generate initial nutrition plan
  Future<NutritionPlanResponse> generateNutritionPlan() async {
    final response = await _service.generateNutritionPlan();
    final plan = _unwrapResponse(response);
    
    // Cache active plan ID
    await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
    
    return plan;
  }

  /// Adjust nutrition plan based on behavior
  Future<NutritionPlanResponse> adjustNutritionPlan(int planId) async {
    final response = await _service.adjustNutritionPlan(planId);
    return _unwrapResponse(response);
  }

  /// Get or generate meals for specific day
  Future<List<MealTemplateResponse>> getMealsForDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await _service.getMealsForDay(planId, dayNumber);
    return _unwrapResponse(response);
  }

  /// Get cached active nutrition plan ID
  Future<int?> getActiveNutritionPlanId() async {
    return await _localStorage.getInt(_activeNutritionPlanKey);
  }

  /// Clear cached plan IDs (e.g., on logout)
  Future<void> clearCache() async {
    await _localStorage.remove(_activeWorkoutPlanKey);
    await _localStorage.remove(_activeNutritionPlanKey);
  }
}

/// Custom exception for recommendation operations
class RecommendationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  RecommendationException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
