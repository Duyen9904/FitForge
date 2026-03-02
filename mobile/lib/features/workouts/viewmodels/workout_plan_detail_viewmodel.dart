import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/workout_plan_models.dart';
import '../repositories/workout_plan_repository.dart';
import '../../missed_workouts/models/missed_workout_models.dart';
import '../../missed_workouts/repositories/missed_workout_repository.dart';
import '../../../shared/enums/reschedule_reason.dart';
import 'workout_plan_detail_state.dart';

/// Provider for WorkoutPlanDetailViewModel
final workoutPlanDetailViewModelProvider = StateNotifierProvider<
    WorkoutPlanDetailViewModel, WorkoutPlanDetailState>((ref) {
  final repository = ref.watch(workoutPlanRepositoryProvider);
  final missedWorkoutRepository = ref.watch(missedWorkoutRepositoryProvider);
  return WorkoutPlanDetailViewModel(
    repository: repository,
    missedWorkoutRepository: missedWorkoutRepository,
  );
});

/// ViewModel for managing workout plan detail state
class WorkoutPlanDetailViewModel
    extends StateNotifier<WorkoutPlanDetailState> {
  final WorkoutPlanRepository _repository;
  final MissedWorkoutRepository _missedWorkoutRepository;

  WorkoutPlanDetailViewModel({
    required WorkoutPlanRepository repository,
    required MissedWorkoutRepository missedWorkoutRepository,
  })  : _repository = repository,
        _missedWorkoutRepository = missedWorkoutRepository,
        super(const WorkoutPlanDetailState.initial());

  /// Load plan details by ID, then auto-load the week containing today
  /// and select today's session.
  Future<void> loadPlan(int planId) async {
    state = const WorkoutPlanDetailState.loading();

    try {
      final plan = await _repository.getPlanById(planId);
      state = WorkoutPlanDetailState.loaded(plan: plan);

      final (weekNumber, _) = _computeTodayWeekAndIndex(plan);
      await loadSessionsForWeek(planId, weekNumber);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load workout plan detail',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = WorkoutPlanDetailState.error(e.toString());
    }
  }

  /// Select a session by index (no API call; data already in weekSessions)
  void selectSession(int index) {
    final currentState = state;
    if (currentState is WorkoutPlanDetailLoaded &&
        index >= 0 &&
        index < currentState.weekSessions.length) {
      final session = currentState.weekSessions[index];
      state = WorkoutPlanDetailLoaded(
        plan: currentState.plan,
        selectedSessionIndex: index,
        sessionLoadingState: SessionLoadingState.loaded,
        loadedSession: session,
        sessionError: currentState.sessionError,
        currentWeekNumber: currentState.currentWeekNumber,
        totalWeeks: currentState.totalWeeks,
        weekSessions: currentState.weekSessions,
        weekLabel: currentState.weekLabel,
      );
    }
  }

  /// Compute the week number and session index for today, or (1, 0) if today
  /// is outside the plan date range.
  (int weekNumber, int sessionIndex) _computeTodayWeekAndIndex(
      WorkoutPlanResponse plan) {
    final totalWeeks = plan.durationWeeks ?? 1;
    if (totalWeeks < 1) return (1, 0);

    DateTime? startDate;
    if (plan.startDate != null) {
      try {
        startDate = DateTime.parse(plan.startDate!);
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
      } catch (_) {}
    }
    if (startDate == null) return (1, 0);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysSinceStart = todayDate.difference(startDate).inDays;

    if (daysSinceStart < 0) return (1, 0);

    final totalDays = totalWeeks * 7;
    if (daysSinceStart >= totalDays) return (totalWeeks, 0);

    final weekNumber = (daysSinceStart ~/ 7) + 1;
    final dayInWeek = daysSinceStart % 7;
    return (weekNumber, dayInWeek);
  }

  /// Find the session index whose scheduledDate equals today.
  int _findTodaySessionIndex(List<WorkoutSessionResponse> sessions) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (var i = 0; i < sessions.length; i++) {
      final d = sessions[i].scheduledDate;
      if (d != null) {
        final sessionDate = DateTime(d.year, d.month, d.day);
        if (sessionDate == todayDate) return i;
      }
    }
    return 0;
  }

  /// Load all sessions for a specific week
  Future<void> loadSessionsForWeek(int planId, int weekNumber) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    final totalWeeks = currentState.plan.durationWeeks ?? 1;
    final isInitialLoad = currentState.weekSessions.isEmpty;
    final (todayWeek, todayIndex) =
        _computeTodayWeekAndIndex(currentState.plan);
    final shouldFocusToday =
        isInitialLoad && weekNumber == todayWeek;

    state = WorkoutPlanDetailLoaded(
      plan: currentState.plan,
      selectedSessionIndex: shouldFocusToday ? todayIndex : 0,
      sessionLoadingState: SessionLoadingState.loading,
      loadedSession: null,
      sessionError: null,
      currentWeekNumber: weekNumber,
      totalWeeks: totalWeeks,
      weekSessions: currentState.weekSessions,
      weekLabel: currentState.weekLabel,
    );

    try {
      final sessions = await _repository.getSessionsForWeek(planId, weekNumber);
      final weekLabel = _computeWeekLabel(
        plan: currentState.plan,
        weekNumber: weekNumber,
        weekSessions: sessions,
      );

      final selectedIndex = shouldFocusToday && sessions.isNotEmpty
          ? _findTodaySessionIndex(sessions)
          : (shouldFocusToday ? todayIndex : 0);
      final loadedSession =
          sessions.isNotEmpty ? sessions[selectedIndex] : null;

      final latestState = state;
      if (latestState is WorkoutPlanDetailLoaded &&
          latestState.currentWeekNumber == weekNumber) {
        state = WorkoutPlanDetailLoaded(
          plan: latestState.plan,
          selectedSessionIndex: selectedIndex,
          sessionLoadingState: SessionLoadingState.loaded,
          loadedSession: loadedSession,
          sessionError: null,
          currentWeekNumber: weekNumber,
          totalWeeks: totalWeeks,
          weekSessions: sessions,
          weekLabel: weekLabel,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load sessions for week $weekNumber',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );

      final latestState = state;
      if (latestState is WorkoutPlanDetailLoaded) {
        state = WorkoutPlanDetailLoaded(
          plan: latestState.plan,
          selectedSessionIndex: latestState.selectedSessionIndex,
          sessionLoadingState: SessionLoadingState.error,
          sessionError: e.toString(),
          currentWeekNumber: weekNumber,
          totalWeeks: totalWeeks,
          weekSessions: latestState.weekSessions,
          weekLabel: latestState.weekLabel,
        );
      }
    }
  }

  String _computeWeekLabel({
    required WorkoutPlanResponse plan,
    required int weekNumber,
    required List<WorkoutSessionResponse> weekSessions,
  }) {
    DateTime? weekStart;
    DateTime? weekEnd;

    if (plan.startDate != null) {
      try {
        final startDate = DateTime.parse(plan.startDate!);
        weekStart = startDate.add(Duration(days: (weekNumber - 1) * 7));
        weekEnd = weekStart.add(const Duration(days: 6));
      } catch (_) {}
    }

    if (weekStart == null && weekSessions.isNotEmpty) {
      final first = weekSessions.first.scheduledDate;
      final last = weekSessions.last.scheduledDate;
      if (first != null && last != null) {
        weekStart = first;
        weekEnd = last;
      }
    }

    if (weekStart == null || weekEnd == null) {
      return 'Week $weekNumber';
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endDate = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);

    if ((todayDate.isAtSameMomentAs(startDate) ||
            todayDate.isAfter(startDate)) &&
        (todayDate.isAtSameMomentAs(endDate) || todayDate.isBefore(endDate))) {
      return 'This Week';
    }

    final formatter = DateFormat('d/M/yyyy');
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }

  /// Go to next week
  Future<void> goToNextWeek() async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;
    if (currentState.currentWeekNumber >= currentState.totalWeeks) return;

    await loadSessionsForWeek(
      currentState.plan.planId,
      currentState.currentWeekNumber + 1,
    );
  }

  /// Go to previous week
  Future<void> goToPrevWeek() async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;
    if (currentState.currentWeekNumber <= 1) return;

    await loadSessionsForWeek(
      currentState.plan.planId,
      currentState.currentWeekNumber - 1,
    );
  }

  /// Refresh plan details
  Future<void> refresh(int planId) async {
    await loadPlan(planId);
  }

  /// Duplicate the current workout plan
  Future<void> duplicatePlan(String newName) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    try {
      await _repository.duplicatePlan(
        currentState.plan.planId,
        newPlanName: newName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to duplicate workout plan',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete the current workout plan
  Future<void> deletePlan() async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    try {
      await _repository.deletePlan(currentState.plan.planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete workout plan',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Toggle active status of the current workout plan
  Future<void> toggleActive() async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    try {
      // Optimistically update
      final updatedPlan = currentState.plan.copyWith(
        isActive: !currentState.plan.isActive,
      );

      state = WorkoutPlanDetailLoaded(
        plan: updatedPlan,
        selectedSessionIndex: currentState.selectedSessionIndex,
        sessionLoadingState: currentState.sessionLoadingState,
        loadedSession: currentState.loadedSession,
        sessionError: currentState.sessionError,
        currentWeekNumber: currentState.currentWeekNumber,
        totalWeeks: currentState.totalWeeks,
        weekSessions: currentState.weekSessions,
        weekLabel: currentState.weekLabel,
      );

      await _repository.togglePlanActive(currentState.plan.planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to toggle workout plan active status',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      // Rollback on error
      await refresh(currentState.plan.planId);
      rethrow;
    }
  }

  /// Reschedule the currently selected workout session
  Future<void> rescheduleSession(DateTime newDate) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    final session = currentState.loadedSession;
    if (session == null) return;

    try {
      if (session.isMissed && session.missedWorkoutId != null) {
        // Use missed workout reschedule API
        final request = RescheduleMissedWorkoutRequest(
          newDate: newDate,
          notes: 'Rescheduled from workout plan detail',
        );
        await _missedWorkoutRepository.rescheduleMissedWorkout(
          session.missedWorkoutId!,
          request,
        );
      } else {
        // Use session reschedule API
        final request = RescheduleWorkoutSessionRequest(
          newDate: newDate,
          rescheduleReason: RescheduleReason.userInitiated,
        );
        await _repository.rescheduleSession(
          currentState.plan.planId,
          session.sessionId,
          request,
        );
      }

      // Reload the current week to reflect changes
      await loadSessionsForWeek(
        currentState.plan.planId,
        currentState.currentWeekNumber,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to reschedule workout session',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a session exercise from the currently loaded session
  Future<void> deleteSessionExercise(int sessionExerciseId) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    final session = currentState.loadedSession;
    if (session == null) return;

    try {
      await _repository.deleteSessionExercise(
        currentState.plan.planId,
        session.sessionId,
        sessionExerciseId,
      );

      // Reload the current week to reflect changes
      await loadSessionsForWeek(
        currentState.plan.planId,
        currentState.currentWeekNumber,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete session exercise',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update a session exercise within the currently loaded session
  Future<void> updateSessionExercise(
      int sessionExerciseId, UpdateSessionExerciseRequest request) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    final session = currentState.loadedSession;
    if (session == null) return;

    try {
      await _repository.updateSessionExercise(
        currentState.plan.planId,
        session.sessionId,
        sessionExerciseId,
        request,
      );

      // Reload the current week to reflect changes
      await loadSessionsForWeek(
        currentState.plan.planId,
        currentState.currentWeekNumber,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update session exercise',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update plan metadata (name, description, goal, etc.)
  Future<void> updatePlanMetadata(UpdateWorkoutPlanRequest request) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    try {
      await _repository.updatePlan(currentState.plan.planId, request);

      // Reload the plan to reflect changes
      await loadPlan(currentState.plan.planId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update plan metadata',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update session metadata (name, focus area, duration, etc.)
  Future<void> updateSessionMetadata(
      int sessionId, UpdateWorkoutSessionRequest request) async {
    final currentState = state;
    if (currentState is! WorkoutPlanDetailLoaded) return;

    try {
      await _repository.updateSession(
        currentState.plan.planId,
        sessionId,
        request,
      );

      // Reload the current week to reflect changes
      await loadSessionsForWeek(
        currentState.plan.planId,
        currentState.currentWeekNumber,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update session metadata',
        name: 'WorkoutPlanDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
