import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

/// Unified profile summary response from GET /workouts/profile-summary
@freezed
class ProfileSummaryResponse with _$ProfileSummaryResponse {
  const factory ProfileSummaryResponse({
    @Default(0) int totalWorkoutsCompleted,
    ActivityHeatmapData? activityHeatmap,
    @Default([]) List<CheckInPhoto> checkInPhotos,
  }) = _ProfileSummaryResponse;

  factory ProfileSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileSummaryResponseFromJson(json);
}

/// Activity heatmap data for GitHub-style contribution grid
@freezed
class ActivityHeatmapData with _$ActivityHeatmapData {
  const factory ActivityHeatmapData({
    required String startDate,
    required String endDate,
    @Default(0) int totalActiveDays,
    @Default(0) int totalWorkouts,
    @Default([]) List<DailyActivity> dailyActivities,
  }) = _ActivityHeatmapData;

  factory ActivityHeatmapData.fromJson(Map<String, dynamic> json) =>
      _$ActivityHeatmapDataFromJson(json);
}

/// Single day entry in the activity heatmap
@freezed
class DailyActivity with _$DailyActivity {
  const factory DailyActivity({
    required String date,
    @Default(0) int workoutsCompleted,
    @Default(0) int totalMinutes,
    @Default(0) int caloriesBurned,
  }) = _DailyActivity;

  factory DailyActivity.fromJson(Map<String, dynamic> json) =>
      _$DailyActivityFromJson(json);
}

/// Check-in photo from workout completion
@freezed
class CheckInPhoto with _$CheckInPhoto {
  const factory CheckInPhoto({
    int? progressId,
    String? sessionName,
    String? planName,
    String? workoutDate,
    int? durationMinutes,
    String? proofPhotoUrl,
  }) = _CheckInPhoto;

  factory CheckInPhoto.fromJson(Map<String, dynamic> json) =>
      _$CheckInPhotoFromJson(json);
}
