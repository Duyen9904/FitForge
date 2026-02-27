import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_execution_models.freezed.dart';
part 'workout_execution_models.g.dart';

// ========================= RESPONSE MODELS =========================

/// Full workout progress response (from WorkoutExecutionController)
@freezed
class WorkoutProgressResponse with _$WorkoutProgressResponse {
  const factory WorkoutProgressResponse({
    int? progressId,
    int? planId,
    String? planName,
    int? sessionId,
    String? sessionName,
    DateTime? workoutDate,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    @Default(false) bool completed,
    String? performanceNotes,
    int? difficultyRating,
    int? caloriesBurned,
    double? averageHeartRate,
    String? moodRating,
    @Default([]) List<ExerciseLogResponse> exerciseLogs,
  }) = _WorkoutProgressResponse;

  factory WorkoutProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgressResponseFromJson(json);
}

/// Exercise log entry within a workout progress
@freezed
class ExerciseLogResponse with _$ExerciseLogResponse {
  const factory ExerciseLogResponse({
    int? logId,
    int? exerciseId,
    String? exerciseName,
    int? setNumber,
    int? repetitionsCompleted,
    double? weightUsedKg,
    int? restTimeSeconds,
    @Default(true) bool completed,
    @Default(false) bool skipped,
    String? skipReason,
    String? notes,
  }) = _ExerciseLogResponse;

  factory ExerciseLogResponse.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogResponseFromJson(json);
}

/// Workout history summary (for paginated history list)
@freezed
class WorkoutHistoryResponse with _$WorkoutHistoryResponse {
  const factory WorkoutHistoryResponse({
    int? progressId,
    String? planName,
    String? sessionName,
    DateTime? workoutDate,
    int? durationMinutes,
    @Default(false) bool completed,
    int? difficultyRating,
    int? caloriesBurned,
    String? moodRating,
    @Default(0) int exercisesCompleted,
    @Default(0) int exercisesSkipped,
    @Default(0.0) double totalVolumeKg,
  }) = _WorkoutHistoryResponse;

  factory WorkoutHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryResponseFromJson(json);
}

// ========== Weekly Workout Progress ==========

/// Weekly workout progress response from /workouts/weekly-progress
@freezed
class WeeklyWorkoutProgressResponse with _$WeeklyWorkoutProgressResponse {
  const factory WeeklyWorkoutProgressResponse({
    String? weekLabel,
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<DailyWorkoutData> dailyData,
    WeeklySummary? summary,
  }) = _WeeklyWorkoutProgressResponse;

  factory WeeklyWorkoutProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWorkoutProgressResponseFromJson(json);
}

@freezed
class DailyWorkoutData with _$DailyWorkoutData {
  const factory DailyWorkoutData({
    DateTime? date,
    String? dayOfWeek,
    @Default(false) bool isToday,
    @Default(0) int workoutsCompleted,
    @Default(0) int minutesExercised,
    @Default(0) int caloriesBurned,
  }) = _DailyWorkoutData;

  factory DailyWorkoutData.fromJson(Map<String, dynamic> json) =>
      _$DailyWorkoutDataFromJson(json);
}

@freezed
class WeeklySummary with _$WeeklySummary {
  const factory WeeklySummary({
    @Default(0) int totalWorkoutsCompleted,
    @Default(0) int totalMinutesExercised,
    @Default(0) int totalCaloriesBurned,
    @Default(0.0) double averageWorkoutDuration,
  }) = _WeeklySummary;

  factory WeeklySummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklySummaryFromJson(json);
}

// ========== Progress Charts ==========

/// Progress chart response from /workouts/progress/charts
@freezed
class ProgressChartResponse with _$ProgressChartResponse {
  const factory ProgressChartResponse({
    DateTime? fromDate,
    DateTime? toDate,
    @Default([]) List<ExerciseProgressData> weightProgression,
    @Default({}) Map<String, List<VolumeDataPoint>> volumeByMuscleGroup,
    @Default([]) List<FrequencyDataPoint> workoutFrequency,
    @Default([]) List<CaloriesDataPoint> caloriesTrend,
    @Default([]) List<StrengthEstimate> strengthEstimates,
  }) = _ProgressChartResponse;

  factory ProgressChartResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgressChartResponseFromJson(json);
}

@freezed
class ExerciseProgressData with _$ExerciseProgressData {
  const factory ExerciseProgressData({
    int? exerciseId,
    String? exerciseName,
    @Default([]) List<WeightDataPoint> dataPoints,
  }) = _ExerciseProgressData;

  factory ExerciseProgressData.fromJson(Map<String, dynamic> json) =>
      _$ExerciseProgressDataFromJson(json);
}

@freezed
class WeightDataPoint with _$WeightDataPoint {
  const factory WeightDataPoint({
    DateTime? date,
    @Default(0.0) double maxWeight,
    @Default(0.0) double avgWeight,
    @Default(0) int totalReps,
  }) = _WeightDataPoint;

  factory WeightDataPoint.fromJson(Map<String, dynamic> json) =>
      _$WeightDataPointFromJson(json);
}

@freezed
class VolumeDataPoint with _$VolumeDataPoint {
  const factory VolumeDataPoint({
    DateTime? date,
    @Default(0.0) double totalVolume,
    @Default(0) int totalSets,
  }) = _VolumeDataPoint;

  factory VolumeDataPoint.fromJson(Map<String, dynamic> json) =>
      _$VolumeDataPointFromJson(json);
}

@freezed
class FrequencyDataPoint with _$FrequencyDataPoint {
  const factory FrequencyDataPoint({
    String? weekLabel,
    @Default(0) int workoutsCompleted,
    @Default(0) int workoutsPlanned,
  }) = _FrequencyDataPoint;

  factory FrequencyDataPoint.fromJson(Map<String, dynamic> json) =>
      _$FrequencyDataPointFromJson(json);
}

@freezed
class CaloriesDataPoint with _$CaloriesDataPoint {
  const factory CaloriesDataPoint({
    DateTime? date,
    @Default(0) int caloriesBurned,
  }) = _CaloriesDataPoint;

  factory CaloriesDataPoint.fromJson(Map<String, dynamic> json) =>
      _$CaloriesDataPointFromJson(json);
}

@freezed
class StrengthEstimate with _$StrengthEstimate {
  const factory StrengthEstimate({
    int? exerciseId,
    String? exerciseName,
    @Default(0.0) double estimated1RM,
    @Default(0.0) double previousEstimated1RM,
    @Default(0.0) double percentChange,
  }) = _StrengthEstimate;

  factory StrengthEstimate.fromJson(Map<String, dynamic> json) =>
      _$StrengthEstimateFromJson(json);
}

// ========================= REQUEST MODELS =========================

/// Request to start a workout session (POST /workouts/start)
@freezed
class StartWorkoutRequest with _$StartWorkoutRequest {
  const factory StartWorkoutRequest({
    required int sessionId,
  }) = _StartWorkoutRequest;

  factory StartWorkoutRequest.fromJson(Map<String, dynamic> json) =>
      _$StartWorkoutRequestFromJson(json);
}

/// Request to log exercise performance (POST /workouts/{id}/log)
@freezed
class LogExerciseRequest with _$LogExerciseRequest {
  const factory LogExerciseRequest({
    required int exerciseId,
    required int setNumber,
    int? repetitionsCompleted,
    double? weightUsedKg,
    int? restTimeSeconds,
    @Default(true) bool completed,
    String? notes,
  }) = _LogExerciseRequest;

  factory LogExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$LogExerciseRequestFromJson(json);
}

/// Request to complete a workout (POST /workouts/{id}/complete)
@freezed
class CompleteWorkoutRequest with _$CompleteWorkoutRequest {
  const factory CompleteWorkoutRequest({
    required int difficultyRating,
    String? performanceNotes,
    String? moodRating,
  }) = _CompleteWorkoutRequest;

  factory CompleteWorkoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteWorkoutRequestFromJson(json);
}

/// Request to skip an exercise (POST /workouts/{id}/skip)
@freezed
class SkipExerciseRequest with _$SkipExerciseRequest {
  const factory SkipExerciseRequest({
    required int exerciseId,
    required String reason,
    String? notes,
  }) = _SkipExerciseRequest;

  factory SkipExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$SkipExerciseRequestFromJson(json);
}
