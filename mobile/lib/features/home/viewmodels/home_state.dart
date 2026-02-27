import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/home_models.dart';

part 'home_state.freezed.dart';

/// State for home dashboard
@freezed
class HomeState with _$HomeState {
  /// Initial state - nothing loaded yet
  const factory HomeState.initial() = HomeInitial;

  /// Loading dashboard data
  const factory HomeState.loading() = HomeLoading;

  /// Dashboard loaded successfully
  const factory HomeState.loaded({
    required WeeklyWorkoutProgressResponse weeklyProgress,
    ProgressChartResponse? progressCharts,
  }) = HomeLoaded;

  /// Error state
  const factory HomeState.error(String message) = HomeError;
}
