import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/workout_plan_models.dart';
import '../services/workout_plan_service.dart';

/// Provider for WorkoutPlanRepository
final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>((ref) {
  final service = ref.watch(workoutPlanServiceProvider);
  return WorkoutPlanRepository(service: service);
});

/// Repository for workout plan operations
/// Orchestrates between API service and handles error unwrapping
class WorkoutPlanRepository {
  final WorkoutPlanService _service;

  WorkoutPlanRepository({required WorkoutPlanService service})
      : _service = service;

  /// Unwrap ApiResponse and throw if not successful
  T _unwrapResponse<T>(ApiResponse<T> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw WorkoutPlanException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
    if (response.data == null) {
      throw WorkoutPlanException(message: 'No data in response');
    }
    return response.data as T;
  }

  /// Unwrap ApiResponse for void operations
  void _unwrapVoidResponse(ApiResponse<void> response) {
    if (!response.success) {
      final errorMessage =
          response.error?.message ?? response.message ?? 'Request failed';
      throw WorkoutPlanException(
        message: errorMessage,
        fieldErrors: response.error?.fieldErrors,
      );
    }
  }

  /// UC-2.1: Create a new workout plan
  Future<WorkoutPlanResponse> createPlan(
      CreateWorkoutPlanRequest request) async {
    final response = await _service.createPlan(request);
    return _unwrapResponse(response);
  }

  /// Add a session to an existing workout plan
  Future<WorkoutSessionResponse> addSession(
      int planId, CreateWorkoutSessionRequest request) async {
    final response = await _service.addSession(planId, request);
    return _unwrapResponse(response);
  }

  /// Add exercises to a session (batch add)
  Future<WorkoutSessionResponse> addExercises(
      int planId, int sessionId, List<CreateSessionExerciseRequest> exercises) async {
    final response = await _service.addExercises(planId, sessionId, exercises);
    return _unwrapResponse(response);
  }

  /// UC-2.2: Generate AI-powered workout plan
  Future<WorkoutPlanResponse> generateAIPlan(
      GenerateAIPlanRequest request) async {
    final response = await _service.generateAIPlan(request);
    return _unwrapResponse(response);
  }

  /// UC-2.3: Update an existing workout plan
  Future<WorkoutPlanResponse> updatePlan(
      int planId, UpdateWorkoutPlanRequest request) async {
    final response = await _service.updatePlan(planId, request);
    return _unwrapResponse(response);
  }

  /// Update an existing workout session
  Future<WorkoutSessionResponse> updateSession(
      int planId, int sessionId, UpdateWorkoutSessionRequest request) async {
    final response = await _service.updateSession(planId, sessionId, request);
    return _unwrapResponse(response);
  }

  /// UC-2.4: Get workout plan details
  Future<WorkoutPlanResponse> getPlanById(int planId) async {
    final response = await _service.getPlanById(planId);
    return _unwrapResponse(response);
  }

  /// UC-2.5: Toggle workout plan active status
  Future<WorkoutPlanResponse> togglePlanActive(int planId) async {
    final response = await _service.togglePlanActive(planId);
    return _unwrapResponse(response);
  }

  /// UC-2.6: Delete a workout plan
  Future<void> deletePlan(int planId) async {
    final response = await _service.deletePlan(planId);
    _unwrapVoidResponse(response);
  }

  /// Delete a session from a workout plan (cascades to exercises)
  Future<void> deleteSession(int planId, int sessionId) async {
    final response = await _service.deleteSession(planId, sessionId);
    _unwrapVoidResponse(response);
  }

  /// UC-2.7: Duplicate a workout plan
  Future<WorkoutPlanResponse> duplicatePlan(int planId,
      {String? newPlanName}) async {
    final response =
        await _service.duplicatePlan(planId, newPlanName: newPlanName);
    return _unwrapResponse(response);
  }

  /// Get all user workout plans (paginated)
  Future<PageData<WorkoutPlanSummaryResponse>> getUserPlans({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final response = await _service.getUserPlans(
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// Get active user workout plans (paginated)
  Future<PageData<WorkoutPlanSummaryResponse>> getActiveUserPlans({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final response = await _service.getActiveUserPlans(
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// UC-14.2: Filter workout plans
  Future<PageData<WorkoutPlanSummaryResponse>> filterPlans({
    WorkoutPlanFilterRequest? filter,
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final response = await _service.filterPlans(
      filter: filter,
      page: page,
      size: size,
      sort: sort,
    );
    return _unwrapResponse(response);
  }

  /// Get or generate all sessions for a specific week
  Future<List<WorkoutSessionResponse>> getSessionsForWeek(
      int planId, int weekNumber) async {
    final response = await _service.getSessionsForWeek(planId, weekNumber);
    return _unwrapResponse(response);
  }

  /// Reschedule an upcoming workout session
  Future<WorkoutSessionResponse> rescheduleSession(
      int planId, int sessionId, RescheduleWorkoutSessionRequest request) async {
    final response = await _service.rescheduleSession(planId, sessionId, request);
    return _unwrapResponse(response);
  }

  /// Delete a session exercise from a workout session
  Future<void> deleteSessionExercise(
      int planId, int sessionId, int sessionExerciseId) async {
    final response = await _service.deleteSessionExercise(
        planId, sessionId, sessionExerciseId);
    _unwrapVoidResponse(response);
  }

  /// Update a session exercise within a workout session
  Future<WorkoutSessionResponse> updateSessionExercise(
      int planId, int sessionId, int sessionExerciseId,
      UpdateSessionExerciseRequest request) async {
    final response = await _service.updateSessionExercise(
        planId, sessionId, sessionExerciseId, request);
    return _unwrapResponse(response);
  }

  /// Get recommended workout templates for the authenticated user
  Future<List<WorkoutTemplateSummaryResponse>> getRecommendedTemplates({
    int limit = 5,
  }) async {
    final response = await _service.getRecommendedTemplates(limit: limit);
    return _unwrapResponse(response);
  }
}

/// Custom exception for workout plan operations
class WorkoutPlanException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  WorkoutPlanException({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}
