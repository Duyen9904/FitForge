import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/onboarding_request.dart';
import '../models/onboarding_response.dart';

/// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OnboardingService(apiClient: apiClient);
});

/// Service for onboarding API operations
class OnboardingService {
  final ApiClient apiClient;

  OnboardingService({required this.apiClient});

  /// Extract data from ApiResponse wrapper
  T _extractData<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Request failed');
    }
    final data = response['data'];
    if (data == null) {
      throw Exception('No data in response');
    }
    return fromJson(data as Map<String, dynamic>);
  }

  /// Extract boolean data from ApiResponse wrapper
  bool _extractBoolData(Map<String, dynamic> response) {
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Request failed');
    }
    return response['data'] as bool? ?? false;
  }

  /// Get onboarding flow with all steps and user's progress
  /// UC-17.1: Get all onboarding steps with user's current progress
  Future<OnboardingFlowResponse> getOnboardingFlow() async {
    final response = await apiClient.get(ApiConstants.onboardingFlow);

    return _extractData(
      response.data as Map<String, dynamic>,
      OnboardingFlowResponse.fromJson,
    );
  }

  /// Submit user's response for an onboarding step
  /// UC-17.2-9: Submit user's response for an onboarding step
  Future<OnboardingProgressResponse> submitStepResponse(
    int stepId,
    SubmitOnboardingStepRequest request,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.onboardingSteps}/$stepId/submit',
      data: request.toJson(),
    );

    return _extractData(
      response.data as Map<String, dynamic>,
      OnboardingProgressResponse.fromJson,
    );
  }

  /// Skip an optional onboarding step
  /// UC-17.10: Skip a non-required onboarding step
  Future<OnboardingProgressResponse> skipStep(int stepId) async {
    final response = await apiClient.post(
      '${ApiConstants.onboardingSteps}/$stepId/skip',
    );

    return _extractData(
      response.data as Map<String, dynamic>,
      OnboardingProgressResponse.fromJson,
    );
  }

  /// Mark onboarding as complete
  /// UC-17.13: Mark onboarding as complete after all required steps are done
  Future<void> completeOnboarding() async {
    final response = await apiClient.post(ApiConstants.onboardingComplete);

    final data = response.data as Map<String, dynamic>;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw Exception(data['message'] ?? 'Failed to complete onboarding');
    }
  }

  /// Check if user has completed onboarding
  Future<bool> checkOnboardingStatus() async {
    final response = await apiClient.get(ApiConstants.onboardingStatus);

    return _extractBoolData(response.data as Map<String, dynamic>);
  }
}
