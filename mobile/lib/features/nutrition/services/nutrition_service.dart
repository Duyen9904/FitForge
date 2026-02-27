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

  Future<ApiResponse<NutritionLog>> logMeal(
    LogMealRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionMeals,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionLog.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NutritionLog>> logMealFromTemplate(
    LogMealFromTemplateRequestDto dto,
  ) async {
    final response = await apiClient.post(
      ApiConstants.nutritionMealsFromTemplate,
      data: dto.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NutritionLog.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<NutritionLog>>> getDailyMeals(DateTime? date) async {
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
            .map((item) => NutritionLog.fromJson(item as Map<String, dynamic>))
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


}

