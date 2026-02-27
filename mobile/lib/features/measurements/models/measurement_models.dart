import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/date_utils.dart';

part 'measurement_models.freezed.dart';
part 'measurement_models.g.dart';

/// Single measurement record response - matches backend MeasurementResponse
@freezed
class MeasurementResponse with _$MeasurementResponse {
  const factory MeasurementResponse({
    int? measurementId,
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? measurementDate,
    double? weightKg,
    double? bodyFatPercentage,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighsCm,
    String? notes,
    // InBody-specific
    double? skeletalMuscleMass,
    double? bodyFatMass,
    double? bodyWaterLiters,
    int? basalMetabolicRate,
    int? visceralFatLevel,
    double? waistHipRatio,
    int? inBodyScore,
    String? source,
    // Change indicators
    double? weightChange,
    double? bodyFatChange,
  }) = _MeasurementResponse;

  factory MeasurementResponse.fromJson(Map<String, dynamic> json) =>
      _$MeasurementResponseFromJson(json);
}

/// Request to record a body measurement - matches backend RecordMeasurementRequest
@freezed
class RecordMeasurementRequest with _$RecordMeasurementRequest {
  const factory RecordMeasurementRequest({
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? measurementDate,
    double? weightKg,
    double? bodyFatPercentage,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighsCm,
    double? skeletalMuscleMass,
    double? bodyFatMass,
    double? bodyWaterLiters,
    int? basalMetabolicRate,
    int? visceralFatLevel,
    double? waistHipRatio,
    int? inBodyScore,
    String? notes,
  }) = _RecordMeasurementRequest;

  factory RecordMeasurementRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordMeasurementRequestFromJson(json);
}

/// Trend point for history charts - matches backend TrendPoint
@freezed
class TrendPoint with _$TrendPoint {
  const factory TrendPoint({
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? date,
    double? value,
  }) = _TrendPoint;

  factory TrendPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendPointFromJson(json);
}

/// Weight/body fat/waist trends - matches backend MeasurementTrendResponse
@freezed
class MeasurementTrendResponse with _$MeasurementTrendResponse {
  const factory MeasurementTrendResponse({
    @Default([]) List<TrendPoint> weightTrend,
    @Default([]) List<TrendPoint> bodyFatTrend,
    @Default([]) List<TrendPoint> waistTrend,
  }) = _MeasurementTrendResponse;

  factory MeasurementTrendResponse.fromJson(Map<String, dynamic> json) =>
      _$MeasurementTrendResponseFromJson(json);
}

/// Progress summary - matches backend ProgressIndicators
@freezed
class ProgressIndicators with _$ProgressIndicators {
  const factory ProgressIndicators({
    double? totalWeightChange,
    double? totalBodyFatChange,
    double? averageWeeklyWeightChange,
    String? overallTrend,
  }) = _ProgressIndicators;

  factory ProgressIndicators.fromJson(Map<String, dynamic> json) =>
      _$ProgressIndicatorsFromJson(json);
}

/// Goal vs current comparison - matches backend GoalComparison
@freezed
class GoalComparison with _$GoalComparison {
  const factory GoalComparison({
    double? currentWeight,
    double? targetWeight,
    double? remainingToTarget,
    double? percentageComplete,
  }) = _GoalComparison;

  factory GoalComparison.fromJson(Map<String, dynamic> json) =>
      _$GoalComparisonFromJson(json);
}

/// Measurement history with trends - matches backend MeasurementHistoryResponse
@freezed
class MeasurementHistoryResponse with _$MeasurementHistoryResponse {
  const factory MeasurementHistoryResponse({
    @Default([]) List<MeasurementResponse> measurements,
    MeasurementTrendResponse? trends,
    ProgressIndicators? progressIndicators,
    GoalComparison? goalComparison,
  }) = _MeasurementHistoryResponse;

  factory MeasurementHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MeasurementHistoryResponseFromJson(json);
}
