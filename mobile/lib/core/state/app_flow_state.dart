import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/measurements/repositories/measurement_repository.dart';
import '../../features/onboarding/repositories/onboarding_repository.dart';

part 'app_flow_state.freezed.dart';

@freezed
class AppFlowState with _$AppFlowState {
  const factory AppFlowState({
    required bool onboardingComplete,
    required bool measurementComplete,
  }) = _AppFlowState;
}

final appFlowStateProvider = StateNotifierProvider<AppFlowStateNotifier, AppFlowState?>((ref) {
  return AppFlowStateNotifier(ref);
});

class AppFlowStateNotifier extends StateNotifier<AppFlowState?> {
  final Ref _ref;
  
  AppFlowStateNotifier(this._ref) : super(null);
  
  /// Check and cache the user's flow status
  Future<void> checkFlowStatus({bool forceRefresh = false}) async {
    try {
      final onboardingRepo = _ref.read(onboardingRepositoryProvider);
      final isOnboardingComplete = await onboardingRepo.isOnboardingComplete(
        forceRefresh: forceRefresh,
      );
      
      bool hasMeasurements = false;
      if (isOnboardingComplete) {
        final measurementRepo = _ref.read(measurementRepositoryProvider);
        try {
          await measurementRepo.getLatestMeasurement();
          hasMeasurements = true;
        } catch (_) {
          hasMeasurements = false;
        }
      }
      
      state = AppFlowState(
        onboardingComplete: isOnboardingComplete,
        measurementComplete: hasMeasurements,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to check flow status',
        name: 'AppFlowStateNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      // Fail closed: assume onboarding is incomplete (safer for new users)
      state = const AppFlowState(
        onboardingComplete: false,
        measurementComplete: false,
      );
    }
  }
  
  /// Clear flow state on logout
  void clear() {
    state = null;
  }
}
