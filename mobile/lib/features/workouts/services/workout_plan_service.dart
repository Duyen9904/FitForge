import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../exercises/models/exercise_models.dart';
import '../models/workout_plan_models.dart';

/// Provider for WorkoutPlanService
final workoutPlanServiceProvider = Provider<WorkoutPlanService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkoutPlanService(apiClient: apiClient);
});

/// Service for workout plan API operations.
/// All methods return [ApiResponse] to preserve error details.
class WorkoutPlanService {
  final ApiClient apiClient;

  WorkoutPlanService({required this.apiClient});

  /// Fetch all fitness goals from /goals API
  Future<ApiResponse<List<GoalResponse>>> getAllGoals() async {
    final response = await apiClient.get(ApiConstants.goals);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => GoalResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Fetch all muscle groups from /muscle-groups API
  Future<ApiResponse<List<MuscleGroup>>> getAllMuscleGroups() async {
    final response = await apiClient.get(ApiConstants.muscleGroups);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map((item) => MuscleGroup.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// UC-2.1: Create a new workout plan
  Future<ApiResponse<WorkoutPlanResponse>> createPlan(
      CreateWorkoutPlanRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutPlans,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Add a session to an existing workout plan
  Future<ApiResponse<WorkoutSessionResponse>> addSession(
      int planId, CreateWorkoutSessionRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutPlanSessions(planId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Add exercises to a session (batch add)
  Future<ApiResponse<WorkoutSessionResponse>> addExercises(
      int planId, int sessionId, List<CreateSessionExerciseRequest> exercises) async {
    final response = await apiClient.post(
      ApiConstants.workoutSessionExercises(planId, sessionId),
      data: exercises.map((e) => e.toJson()).toList(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-2.2: Generate AI-powered workout plan
  Future<ApiResponse<WorkoutPlanResponse>> generateAIPlan(
      GenerateAIPlanRequest request) async {
    final response = await apiClient.post(
      ApiConstants.workoutPlansGenerate,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-2.3: Update an existing workout plan
  Future<ApiResponse<WorkoutPlanResponse>> updatePlan(
      int planId, UpdateWorkoutPlanRequest request) async {
    final response = await apiClient.put(
      ApiConstants.workoutPlanById(planId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update an existing workout session
  Future<ApiResponse<WorkoutSessionResponse>> updateSession(
      int planId, int sessionId, UpdateWorkoutSessionRequest request) async {
    final response = await apiClient.put(
      ApiConstants.workoutSessionById(planId, sessionId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-2.4: Get workout plan details
  Future<ApiResponse<WorkoutPlanResponse>> getPlanById(int planId) async {
    final response = await apiClient.get(
      ApiConstants.workoutPlanById(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-2.5: Toggle workout plan active status
  Future<ApiResponse<WorkoutPlanResponse>> togglePlanActive(int planId) async {
    final response = await apiClient.patch(
      ApiConstants.workoutPlanToggleActive(planId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// UC-2.6: Delete a workout plan
  Future<ApiResponse<void>> deletePlan(int planId) async {
    final response = await apiClient.delete(
      ApiConstants.workoutPlanById(planId),
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      return const ApiResponse(success: true, data: null);
    }
    return ApiResponse.fromJson(data, (_) {});
  }

  /// Delete a session from a workout plan
  Future<ApiResponse<void>> deleteSession(int planId, int sessionId) async {
    final response = await apiClient.delete(
      ApiConstants.workoutSessionById(planId, sessionId),
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      return const ApiResponse(success: true, data: null);
    }
    return ApiResponse.fromJson(data, (_) {});
  }

  /// UC-2.7: Duplicate a workout plan
  Future<ApiResponse<WorkoutPlanResponse>> duplicatePlan(
      int planId, {String? newPlanName}) async {
    final queryParams = <String, dynamic>{
      if (newPlanName != null) 'newPlanName': newPlanName,
    };

    final response = await apiClient.post(
      ApiConstants.workoutPlanDuplicate(planId),
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutPlanResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get all user workout plans (paginated)
  Future<ApiResponse<PageData<WorkoutPlanSummaryResponse>>> getUserPlans({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };

    final response = await apiClient.get(
      ApiConstants.workoutPlans,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<WorkoutPlanSummaryResponse>.fromJson(
        json as Map<String, dynamic>,
        (item) => WorkoutPlanSummaryResponse.fromJson(
            item as Map<String, dynamic>),
      ),
    );
  }

  /// Get active user workout plans (paginated)
  Future<ApiResponse<PageData<WorkoutPlanSummaryResponse>>> getActiveUserPlans({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };

    final response = await apiClient.get(
      ApiConstants.workoutPlansActive,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<WorkoutPlanSummaryResponse>.fromJson(
        json as Map<String, dynamic>,
        (item) => WorkoutPlanSummaryResponse.fromJson(
            item as Map<String, dynamic>),
      ),
    );
  }

  /// UC-14.2: Filter workout plans
  Future<ApiResponse<PageData<WorkoutPlanSummaryResponse>>> filterPlans({
    WorkoutPlanFilterRequest? filter,
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
      if (filter?.isActive != null) 'isActive': filter!.isActive,
      if (filter?.fitnessGoal != null) 'fitnessGoal': filter!.fitnessGoal,
      if (filter?.muscleGroupId != null)
        'muscleGroupId': filter!.muscleGroupId,
      if (filter?.aiGenerated != null) 'aiGenerated': filter!.aiGenerated,
      if (filter?.startDate != null) 'startDate': filter!.startDate,
      if (filter?.endDate != null) 'endDate': filter!.endDate,
    };

    final response = await apiClient.get(
      ApiConstants.workoutPlansFilter,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<WorkoutPlanSummaryResponse>.fromJson(
        json as Map<String, dynamic>,
        (item) => WorkoutPlanSummaryResponse.fromJson(
            item as Map<String, dynamic>),
      ),
    );
  }

  /// Get or generate all sessions for a specific week
  Future<ApiResponse<List<WorkoutSessionResponse>>> getSessionsForWeek(
      int planId, int weekNumber) async {
    final response = await apiClient.get(
      ApiConstants.workoutPlanSessionsWeek(planId, weekNumber),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((item) => WorkoutSessionResponse.fromJson(
              item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Reschedule an upcoming workout session
  Future<ApiResponse<WorkoutSessionResponse>> rescheduleSession(
      int planId, int sessionId, RescheduleWorkoutSessionRequest request) async {
    final response = await apiClient.put(
      ApiConstants.workoutSessionReschedule(planId, sessionId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a session exercise from a workout session
  Future<ApiResponse<void>> deleteSessionExercise(
      int planId, int sessionId, int sessionExerciseId) async {
    final response = await apiClient.delete(
      ApiConstants.sessionExercise(planId, sessionId, sessionExerciseId),
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      return const ApiResponse(success: true, data: null);
    }
    return ApiResponse.fromJson(data, (_) {});
  }

  /// Update a session exercise within a workout session
  Future<ApiResponse<WorkoutSessionResponse>> updateSessionExercise(
      int planId, int sessionId, int sessionExerciseId,
      UpdateSessionExerciseRequest request) async {
    final response = await apiClient.put(
      ApiConstants.sessionExercise(planId, sessionId, sessionExerciseId),
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WorkoutSessionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get recommended workout templates for the authenticated user
  Future<ApiResponse<List<WorkoutTemplateSummaryResponse>>>
      getRecommendedTemplates({int limit = 5}) async {
    final response = await apiClient.get(
      ApiConstants.workoutTemplatesRecommended,
      queryParameters: {
        'limit': limit,
      },
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json as List;
        return list
            .map(
              (item) => WorkoutTemplateSummaryResponse.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
  }
}
