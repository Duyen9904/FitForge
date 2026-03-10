import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_requests.dart';

final nutritionServiceProvider = Provider<NutritionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NutritionService(apiClient: apiClient);
});

class NutritionService {
  final ApiClient apiClient;

  NutritionService({required this.apiClient});

  Future<ApiResponse<NutritionPlan>> createNutritionPlan(
    CreateNutritionPlanRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionPlans,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionPlan>> getActivePlan() async {
    final response = await apiClient.get(
      ApiConstants.nutritionPlansActive,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionPlan>> updateNutritionPlan(
    int planId,
    UpdateNutritionPlanRequestDto dto,
  ) async {
    final response = await apiClient.put(
      ApiConstants.nutritionPlanById(planId),
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deletePlan(int planId) async {
    final response = await apiClient.delete(
      ApiConstants.nutritionPlanById(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => null,
    );
  }

  Future<ApiResponse<NutritionPlan>> deactivatePlan(int planId) async {
    final response = await apiClient.patch(
      ApiConstants.nutritionPlanDeactivate(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<NutritionDay>>> getPlanDays(int planId) async {
    final response = await apiClient.get(
      ApiConstants.nutritionPlanDays(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) => NutritionDay.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<NutritionDay>> getPlanDay(
    int planId,
    int dayNumber,
  ) async {
    final response = await apiClient.get(
      ApiConstants.nutritionPlanDay(planId, dayNumber),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionDay.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PlanMeal>> logMeal(
    LogMealRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionMeals,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PlanMeal.fromJson(json as Map<String, dynamic>),
    );
  }


  Future<ApiResponse<List<PlanMeal>>> getDailyMeals(DateTime? date) async {
    final response = await apiClient.get(
      ApiConstants.nutritionMeals,
      queryParameters: date != null
          ? {
              'date': date.toIso8601String().split('T').first,
            }
          : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => PlanMeal.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<DailyNutritionSummary>> getDailySummary(
    DateTime? date,
  ) async {
    final response = await apiClient.get(
      ApiConstants.nutritionSummary,
      queryParameters: date != null
          ? {
              'date': date.toIso8601String().split('T').first,
            }
          : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => DailyNutritionSummary.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResponse<List<CheatMealLog>>> getUncompensatedCheatMeals() async {
    final response = await apiClient.get(
      ApiConstants.nutritionCheatMeals,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) => CheatMealLog.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<List<CompensationAction>>> getCompensationOptions(
    int cheatMealLogId,
  ) async {
    final response = await apiClient.get(
      ApiConstants.nutritionCompensationOptions(cheatMealLogId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) =>
                  CompensationAction.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<CompensationAction>> selectCompensation(
    int cheatMealLogId,
    SelectCompensationRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionSelectCompensation(cheatMealLogId),
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => CompensationAction.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResponse<NutritionDashboard>> getDashboard() async {
    final response = await apiClient.get(
      ApiConstants.nutritionDashboard,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionDashboard.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResponse<MealTemplate>> createMealTemplate(
    CreateMealTemplateRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionTemplates,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MealTemplate.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResponse<List<MealTemplate>>> getMealTemplates() async {
    final response = await apiClient.get(
      ApiConstants.nutritionTemplates,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) => MealTemplate.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<void>> deleteMealTemplate(int templateId) async {
    final response = await apiClient.delete(
      ApiConstants.nutritionTemplateById(templateId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => null,
    );
  }

  Future<ApiResponse<NutritionPlan>> generateRecommendedPlan() async {
    final response = await apiClient.post(
      ApiConstants.recommendationsNutritionGenerate,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionPlan>> adjustPlanBasedOnBehavior(
    int planId,
  ) async {
    final response = await apiClient.post(
      ApiConstants.recommendationsNutritionAdjust(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<MealTemplate>>> getMealsForDay(
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
            .map(
              (item) => MealTemplate.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<List<DailyNutritionSummary>>> getWeeklyTotals(
    DateTime weekStart,
  ) async {
    final response = await apiClient.get(
      ApiConstants.nutritionWeekly,
      queryParameters: {
        'weekStart': weekStart.toIso8601String().split('T').first,
      },
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) => DailyNutritionSummary.fromJson(
                  item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  // ========== Plan Meals ==========

  Future<ApiResponse<PlanMeal>> scheduleMeal(
    ScheduleMealRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionMealsSchedule,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PlanMeal.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PlanMeal>> completePlanMeal(
    int planMealId,
  ) async {
    final response = await apiClient.put(
      ApiConstants.nutritionMealComplete(planMealId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PlanMeal.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<DayMeal>> completeDayMeal(
    int dayMealId, {
    String? proofPhotoUrl,
  }) async {
    final response = await apiClient.put(
      ApiConstants.nutritionDayMealComplete(dayMealId),
      data: proofPhotoUrl != null ? {'proofPhotoUrl': proofPhotoUrl} : null,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => DayMeal.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PlanMeal>> skipPlanMeal(
    int planMealId,
  ) async {
    final response = await apiClient.put(
      ApiConstants.nutritionMealSkip(planMealId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PlanMeal.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<MealTemplate>> getMealTemplateById(
    int templateId,
  ) async {
    final response = await apiClient.get(
      ApiConstants.nutritionTemplateById(templateId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => MealTemplate.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionPlan>> generateAiPlan() async {
    final response = await apiClient.post(
      ApiConstants.nutritionGenerateAi,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionPlan>> adjustPlanWithAi(
    int planId,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionAdjustAi(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
    );
  }
}
