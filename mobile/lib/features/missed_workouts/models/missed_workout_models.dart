import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums/enums.dart';

part 'missed_workout_models.freezed.dart';
part 'missed_workout_models.g.dart';

// ========================= RESPONSE MODELS =========================

/// Missed workout response (from GET /missed-workouts)
@freezed
class MissedWorkoutResponse with _$MissedWorkoutResponse {
  const factory MissedWorkoutResponse({
    required int missedWorkoutId,
    int? sessionId,
    String? sessionName,
    String? planName,
    DateTime? scheduledDate,
    DateTime? missedDate,
    MissedWorkoutReason? reason,
    String? customReasonText,
    @Default(false) bool isReplanned,
    String? replanStrategy,
    @Default([]) List<CompensationActionResponse> compensationActions,
  }) = _MissedWorkoutResponse;

  factory MissedWorkoutResponse.fromJson(Map<String, dynamic> json) =>
      _$MissedWorkoutResponseFromJson(json);
}

/// Compensation action within a missed workout
@freezed
class CompensationActionResponse with _$CompensationActionResponse {
  const factory CompensationActionResponse({
    int? compensationId,
    String? triggerType,
    String? status,
    String? statusDisplayName,
    String? actionType,
    String? actionDescription,
    DateTime? scheduledDate,
    DateTime? validUntilDate,
    @Default(false) bool isCompleted,
    int? calorieAdjustment,
    String? details,
    DateTime? createdAt,
    DateTime? completedAt,
    RescheduleReason? rescheduleReason,
    CompensationType? compensationType,
    int? daysRemaining,
    String? progressStatus,
  }) = _CompensationActionResponse;

  factory CompensationActionResponse.fromJson(Map<String, dynamic> json) =>
      _$CompensationActionResponseFromJson(json);
}

/// Makeup workout option (UC-6.2)
@freezed
class MakeupWorkoutOptionResponse with _$MakeupWorkoutOptionResponse {
  const factory MakeupWorkoutOptionResponse({
    MakeupOption? option,
    String? description,
    String? detailedExplanation,
    @Default([]) List<DateTime> affectedDates,
    int? estimatedRecoveryDays,
    String? recommendation,
  }) = _MakeupWorkoutOptionResponse;

  factory MakeupWorkoutOptionResponse.fromJson(Map<String, dynamic> json) =>
      _$MakeupWorkoutOptionResponseFromJson(json);
}

/// Active makeup workout response
@freezed
class MakeupWorkoutResponse with _$MakeupWorkoutResponse {
  const factory MakeupWorkoutResponse({
    int? makeupWorkoutId,
    int? missedWorkoutId,
    String? sessionName,
    DateTime? scheduledDate,
    @Default(false) bool isCompleted,
    String? makeupType,
    String? notes,
  }) = _MakeupWorkoutResponse;

  factory MakeupWorkoutResponse.fromJson(Map<String, dynamic> json) =>
      _$MakeupWorkoutResponseFromJson(json);
}

/// Missed workout report (UC-6.4)
@freezed
class MissedWorkoutReportResponse with _$MissedWorkoutReportResponse {
  const factory MissedWorkoutReportResponse({
    @Default(0) int totalMissedWorkouts,
    @Default(0) int totalCompletedWorkouts,
    double? adherencePercentage,
    int? compensationCompletionRate,
    MissedWorkoutPatterns? patterns,
    @Default([]) List<String> recommendations,
  }) = _MissedWorkoutReportResponse;

  factory MissedWorkoutReportResponse.fromJson(Map<String, dynamic> json) =>
      _$MissedWorkoutReportResponseFromJson(json);
}

/// Patterns within the missed workout report
@freezed
class MissedWorkoutPatterns with _$MissedWorkoutPatterns {
  const factory MissedWorkoutPatterns({
    @Default({}) Map<String, int> byDayOfWeek,
    @Default({}) Map<String, int> byReason,
    String? mostMissedDay,
    String? mostCommonReason,
  }) = _MissedWorkoutPatterns;

  factory MissedWorkoutPatterns.fromJson(Map<String, dynamic> json) =>
      _$MissedWorkoutPatternsFromJson(json);
}

// ========================= REQUEST MODELS =========================

/// Request to select a makeup option (POST /{id}/makeup)
@freezed
class SelectMakeupOptionRequest with _$SelectMakeupOptionRequest {
  const factory SelectMakeupOptionRequest({
    required MakeupOption selectedOption,
  }) = _SelectMakeupOptionRequest;

  factory SelectMakeupOptionRequest.fromJson(Map<String, dynamic> json) =>
      _$SelectMakeupOptionRequestFromJson(json);
}

/// Request to reschedule a missed workout (PUT /{id}/reschedule)
@freezed
class RescheduleMissedWorkoutRequest with _$RescheduleMissedWorkoutRequest {
  const factory RescheduleMissedWorkoutRequest({
    required DateTime newDate,
    String? notes,
  }) = _RescheduleMissedWorkoutRequest;

  factory RescheduleMissedWorkoutRequest.fromJson(
          Map<String, dynamic> json) =>
      _$RescheduleMissedWorkoutRequestFromJson(json);
}
