import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums/enums.dart';

part 'nutrition_requests.freezed.dart';
part 'nutrition_requests.g.dart';

@freezed
class CreateNutritionPlanRequestDto with _$CreateNutritionPlanRequestDto {
  const factory CreateNutritionPlanRequestDto({
    required String planName,
    int? goalId,
    required int dailyCalorieTarget,
    required double proteinPercentage,
    required double carbsPercentage,
    required double fatsPercentage,
    int? cheatMealsPerWeek,
    bool? autoAdjustEnabled,
  }) = _CreateNutritionPlanRequestDto;

  factory CreateNutritionPlanRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateNutritionPlanRequestDtoFromJson(json);
}

@freezed
class UpdateNutritionPlanRequestDto with _$UpdateNutritionPlanRequestDto {
  const factory UpdateNutritionPlanRequestDto({
    String? planName,
    int? goalId,
    int? dailyCalorieTarget,
    double? proteinPercentage,
    double? carbsPercentage,
    double? fatsPercentage,
    int? cheatMealsPerWeek,
    bool? autoAdjustEnabled,
  }) = _UpdateNutritionPlanRequestDto;

  factory UpdateNutritionPlanRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateNutritionPlanRequestDtoFromJson(json);
}

@freezed
class LogMealRequestDto with _$LogMealRequestDto {
  const factory LogMealRequestDto({
    int? templateId,
    double? quantityMultiplier,
    MealType? mealType,
    String? foodName,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    DateTime? mealTime,
    DateTime? logDate,
    bool? isCheatMeal,
    bool? replaceExisting,
    String? notes,
  }) = _LogMealRequestDto;

  factory LogMealRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LogMealRequestDtoFromJson(json);
}


@freezed
class CreateMealTemplateRequestDto with _$CreateMealTemplateRequestDto {
  const factory CreateMealTemplateRequestDto({
    required String mealName,
    required MealType mealType,
    String? description,
    required int calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    String? recipeInstructions,
  }) = _CreateMealTemplateRequestDto;

  factory CreateMealTemplateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMealTemplateRequestDtoFromJson(json);
}

@freezed
class SelectCompensationRequestDto with _$SelectCompensationRequestDto {
  const factory SelectCompensationRequestDto({
    required CompensationType compensationType,
    DateTime? preferredDate,
    String? notes,
  }) = _SelectCompensationRequestDto;

  factory SelectCompensationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SelectCompensationRequestDtoFromJson(json);
}

@freezed
class ScheduleMealRequestDto with _$ScheduleMealRequestDto {
  const factory ScheduleMealRequestDto({
    int? planId,
    required int templateId,
    required DateTime scheduledDate,
    required MealType mealType,
  }) = _ScheduleMealRequestDto;

  factory ScheduleMealRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleMealRequestDtoFromJson(json);
}
