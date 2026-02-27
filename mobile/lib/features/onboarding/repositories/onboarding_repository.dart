import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';
import '../models/onboarding_request.dart';
import '../models/onboarding_response.dart';
import '../services/onboarding_service.dart';

/// Provider for OnboardingRepository
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final onboardingService = ref.watch(onboardingServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return OnboardingRepository(
    onboardingService: onboardingService,
    localStorage: localStorage,
  );
});

/// Repository pattern for onboarding - orchestrates service calls
class OnboardingRepository {
  final OnboardingService _onboardingService;
  final LocalStorage _localStorage;

  OnboardingRepository({
    required OnboardingService onboardingService,
    required LocalStorage localStorage,
  })  : _onboardingService = onboardingService,
        _localStorage = localStorage;

  /// Get the complete onboarding flow with user progress
  Future<OnboardingFlowResponse> getOnboardingFlow() async {
    return await _onboardingService.getOnboardingFlow();
  }

  /// Submit a step response with the given data
  Future<OnboardingProgressResponse> submitStep(
    int stepId,
    String responseData,
  ) async {
    final request = SubmitOnboardingStepRequest(responseData: responseData);
    return await _onboardingService.submitStepResponse(stepId, request);
  }

  /// Skip an optional step
  Future<OnboardingProgressResponse> skipStep(int stepId) async {
    return await _onboardingService.skipStep(stepId);
  }

  /// Write to local storage only that the user finished onboarding (no API call).
  /// Use when the user finishes the final step (last step, no step after it).
  Future<void> markOnboardingCompleteLocally() async {
    await _localStorage.setBool(StorageKeys.onboardingCompleted, true);
  }

  /// Complete the onboarding process
  Future<void> completeOnboarding() async {
    await _onboardingService.completeOnboarding();
    // Cache completion status locally
    await _localStorage.setBool(StorageKeys.onboardingCompleted, true);
  }

  /// Check if the user has completed onboarding
  Future<bool> isOnboardingComplete({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Check local cache first (fast path)
      final cachedStatus = await _localStorage.getBool(StorageKeys.onboardingCompleted);
      if (cachedStatus == true) return true;
    }
    
    // Fallback to API for first time, cache miss, or forced refresh
    try {
      final apiStatus = await _onboardingService.checkOnboardingStatus();
      // Cache the result if complete
      if (apiStatus) {
        await _localStorage.setBool(StorageKeys.onboardingCompleted, true);
      } else {
        // Ensure cache is cleared if API says incomplete
        await _localStorage.remove(StorageKeys.onboardingCompleted);
      }
      return apiStatus;
    } catch (e) {
      // Fail closed on error
      return false;
    }
  }
}
