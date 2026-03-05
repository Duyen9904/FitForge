import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';
import '../services/nutrition_service.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return NutritionRepository(
    service: service,
    localStorage: localStorage,
  );
});

class NutritionRepository {
  final NutritionService _service;
  final LocalStorage _localStorage;

  static const String _activeNutritionPlanKey = 'active_nutrition_plan_id';

  NutritionRepository({
    required NutritionService service,
    required LocalStorage localStorage,
  })  : _service = service,
        _localStorage = localStorage;

  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw NutritionException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    return response.data as T;
  }

  Future<NutritionPlan> createNutritionPlan(
    CreateNutritionPlanRequestDto dto,
  ) async {
    final response = await _service.createNutritionPlan(dto);
    final plan = _unwrapResponse(response);
    await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
    return plan;
  }

  Future<NutritionPlan?> getActivePlan() async {
    try {
      final response = await _service.getActivePlan();
      final plan = _unwrapResponse(response);
      await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
      return plan;
    } on NotFoundException {
      // 404 means no active plan exists — treat as null, not an error
      return null;
    }
  }

  Future<NutritionPlan> updateNutritionPlan(
    int planId,
    UpdateNutritionPlanRequestDto dto,
  ) async {
    final response = await _service.updateNutritionPlan(planId, dto);
    final plan = _unwrapResponse(response);
    await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
    return plan;
  }

  Future<NutritionLog> logMeal(LogMealRequestDto dto) async {
    final response = await _service.logMeal(dto);
    return _unwrapResponse(response);
  }

  Future<NutritionLog> logMealFromTemplate(
    LogMealFromTemplateRequestDto dto,
  ) async {
    final response = await _service.logMealFromTemplate(dto);
    return _unwrapResponse(response);
  }

  Future<List<NutritionLog>> getDailyMeals(DateTime? date) async {
    final response = await _service.getDailyMeals(date);
    return _unwrapResponse(response);
  }

  Future<DailyNutritionSummary> getDailySummary(DateTime? date) async {
    final response = await _service.getDailySummary(date);
    return _unwrapResponse(response);
  }

  Future<List<CheatMealLog>> getUncompensatedCheatMeals() async {
    final response = await _service.getUncompensatedCheatMeals();
    return _unwrapResponse(response);
  }

  Future<List<CompensationAction>> getCompensationOptions(
    int cheatMealLogId,
  ) async {
    final response = await _service.getCompensationOptions(cheatMealLogId);
    return _unwrapResponse(response);
  }

  Future<CompensationAction> selectCompensation(
    int cheatMealLogId,
    SelectCompensationRequestDto dto,
  ) async {
    final response = await _service.selectCompensation(cheatMealLogId, dto);
    return _unwrapResponse(response);
  }

  Future<NutritionDashboard> getDashboard() async {
    final response = await _service.getDashboard();
    return _unwrapResponse(response);
  }

  Future<MealTemplate> createMealTemplate(
    CreateMealTemplateRequestDto dto,
  ) async {
    final response = await _service.createMealTemplate(dto);
    return _unwrapResponse(response);
  }

  Future<List<MealTemplate>> getMealTemplates() async {
    final response = await _service.getMealTemplates();
    return _unwrapResponse(response);
  }

  Future<void> deleteMealTemplate(int templateId) async {
    final response = await _service.deleteMealTemplate(templateId);
    _unwrapResponse(response);
  }

  Future<NutritionPlan> generateRecommendedPlan() async {
    final response = await _service.generateRecommendedPlan();
    final plan = _unwrapResponse(response);
    await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
    return plan;
  }

  Future<NutritionPlan> adjustPlanBasedOnBehavior(int planId) async {
    final response = await _service.adjustPlanBasedOnBehavior(planId);
    final plan = _unwrapResponse(response);
    await _localStorage.setInt(_activeNutritionPlanKey, plan.nutritionPlanId);
    return plan;
  }

  Future<List<MealTemplate>> getMealsForDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await _service.getMealsForDay(planId, dayNumber);
    return _unwrapResponse(response);
  }



  Future<int?> getActiveNutritionPlanId() async {
    return _localStorage.getInt(_activeNutritionPlanKey);
  }

  Future<void> clearCache() async {
    await _localStorage.remove(_activeNutritionPlanKey);
  }
}

class NutritionException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  NutritionException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}

