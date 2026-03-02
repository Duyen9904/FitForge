import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_dashboard_models.dart';
import '../repositories/home_repository.dart';
import 'home_state.dart';

/// Provider for HomeViewModel
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeViewModel(repository: repository);
});

/// ViewModel for managing home dashboard state
class HomeViewModel extends StateNotifier<HomeState> {
  final HomeRepository _repository;

  HomeViewModel({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState.initial());

  /// Load the dashboard data (all-in-one API call)
  Future<void> loadDashboard() async {
    state = const HomeState.loading();

    try {
      // Use the new dashboard endpoint
      final dashboard = await _repository.getDashboard();

      // Also load weekly progress for backward compatibility with the chart widget
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final startDate =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

      final weeklyProgress =
          await _repository.getWeeklyProgress(startDate: startDate);

      state = HomeState.loaded(
        weeklyProgress: weeklyProgress,
        dashboard: dashboard,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load home dashboard',
        name: 'HomeViewModel',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback: try loading just weekly progress if dashboard fails
      try {
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final startDate =
            '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
        final weeklyProgress =
            await _repository.getWeeklyProgress(startDate: startDate);
        state = HomeState.loaded(
          weeklyProgress: weeklyProgress,
          dashboard: const HomeDashboardResponse(),
        );
      } catch (fallbackError) {
        state = HomeState.error(e.toString());
      }
    }
  }

  /// Load progress charts (optional detail data)
  Future<void> loadProgressCharts() async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final charts = await _repository.getProgressCharts();
      state = HomeState.loaded(
        weeklyProgress: currentState.weeklyProgress,
        progressCharts: charts,
        dashboard: currentState.dashboard,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load progress charts',
        name: 'HomeViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Keep current state, don't break the dashboard
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }
}
