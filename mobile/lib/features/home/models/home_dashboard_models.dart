import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_dashboard_models.freezed.dart';
part 'home_dashboard_models.g.dart';

/// Dashboard response from GET /workouts/dashboard
@freezed
class HomeDashboardResponse with _$HomeDashboardResponse {
  const factory HomeDashboardResponse({
    TodaySessionInfo? todaySession,
    WeeklyQuickStats? weeklyStats,
    WeeklyProgressData? weeklyProgress,
    @Default([]) List<ActivePlanInfo> activePlans,
  }) = _HomeDashboardResponse;

  factory HomeDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardResponseFromJson(json);
}

/// Today's scheduled workout session
@freezed
class TodaySessionInfo with _$TodaySessionInfo {
  const factory TodaySessionInfo({
    int? planId,
    int? sessionId,
    String? planName,
    String? sessionName,
    int? exerciseCount,
    int? estimatedMinutes,
    String? scheduledDate,
    @Default([]) List<String> targetMuscleGroups,
    @Default(false) bool alreadyCompleted,
  }) = _TodaySessionInfo;

  factory TodaySessionInfo.fromJson(Map<String, dynamic> json) =>
      _$TodaySessionInfoFromJson(json);
}

/// Weekly quick stats
@freezed
class WeeklyQuickStats with _$WeeklyQuickStats {
  const factory WeeklyQuickStats({
    @Default(0) int caloriesBurned,
    @Default(0) int workoutsCompleted,
    @Default(0) int workoutsPlanned,
    @Default(0) int totalMinutes,
    @Default(0) int currentStreak,
  }) = _WeeklyQuickStats;

  factory WeeklyQuickStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyQuickStatsFromJson(json);
}

/// Active workout plan info
@freezed
class ActivePlanInfo with _$ActivePlanInfo {
  const factory ActivePlanInfo({
    int? planId,
    String? planName,
    int? frequencyPerWeek,
    int? durationWeeks,
    @Default(1) int currentWeek,
    @Default(0) int sessionsCompleted,
    @Default(0) int totalSessions,
    @Default(true) bool isActive,
  }) = _ActivePlanInfo;

  factory ActivePlanInfo.fromJson(Map<String, dynamic> json) =>
      _$ActivePlanInfoFromJson(json);
}

/// Weekly progress data (nested in dashboard response)
@freezed
class WeeklyProgressData with _$WeeklyProgressData {
  const factory WeeklyProgressData({
    String? weekLabel,
    String? startDate,
    String? endDate,
    @Default([]) List<DailyProgressData> dailyData,
    WeeklyProgressSummary? summary,
  }) = _WeeklyProgressData;

  factory WeeklyProgressData.fromJson(Map<String, dynamic> json) =>
      _$WeeklyProgressDataFromJson(json);
}

/// Daily progress data point (for bar chart)
@freezed
class DailyProgressData with _$DailyProgressData {
  const factory DailyProgressData({
    String? date,
    String? dayOfWeek,
    @Default(false) bool isToday,
    @Default(0) int workoutsCompleted,
    @Default(0) int minutesExercised,
    @Default(0) int caloriesBurned,
  }) = _DailyProgressData;

  factory DailyProgressData.fromJson(Map<String, dynamic> json) =>
      _$DailyProgressDataFromJson(json);
}

/// Weekly summary stats
@freezed
class WeeklyProgressSummary with _$WeeklyProgressSummary {
  const factory WeeklyProgressSummary({
    @Default(0) int totalWorkoutsCompleted,
    @Default(0) int totalMinutesExercised,
    @Default(0) int totalCaloriesBurned,
    @Default(0.0) double averageWorkoutDuration,
  }) = _WeeklyProgressSummary;

  factory WeeklyProgressSummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklyProgressSummaryFromJson(json);
}
