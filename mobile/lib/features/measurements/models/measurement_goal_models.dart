import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/date_utils.dart';

part 'measurement_goal_models.freezed.dart';
part 'measurement_goal_models.g.dart';

/// Required weekly changes for goal - matches backend RequiredWeeklyChanges
@freezed
class RequiredWeeklyChanges with _$RequiredWeeklyChanges {
  const factory RequiredWeeklyChanges({
    double? weeklyWeightChange,
    double? weeklyBodyFatChange,
    String? recommendation,
  }) = _RequiredWeeklyChanges;

  factory RequiredWeeklyChanges.fromJson(Map<String, dynamic> json) =>
      _$RequiredWeeklyChangesFromJson(json);
}

/// Measurement goal response - matches backend MeasurementGoalResponse
@freezed
class MeasurementGoalResponse with _$MeasurementGoalResponse {
  const factory MeasurementGoalResponse({
    int? goalId,
    double? targetWeightKg,
    double? targetBodyFatPercentage,
    double? targetChestCm,
    double? targetWaistCm,
    double? targetHipsCm,
    double? targetBicepsCm,
    double? targetThighsCm,
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? targetDate,
    bool? isActive,
    String? notes,
    int? daysRemaining,
    RequiredWeeklyChanges? requiredWeeklyChanges,
  }) = _MeasurementGoalResponse;

  factory MeasurementGoalResponse.fromJson(Map<String, dynamic> json) =>
      _$MeasurementGoalResponseFromJson(json);
}

/// Request to set measurement goal - matches backend SetMeasurementGoalRequest
@freezed
class SetMeasurementGoalRequest with _$SetMeasurementGoalRequest {
  const factory SetMeasurementGoalRequest({
    double? targetWeightKg,
    double? targetBodyFatPercentage,
    double? targetChestCm,
    double? targetWaistCm,
    double? targetHipsCm,
    double? targetBicepsCm,
    double? targetThighsCm,
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? targetDate,
    String? notes,
  }) = _SetMeasurementGoalRequest;

  factory SetMeasurementGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$SetMeasurementGoalRequestFromJson(json);
}
