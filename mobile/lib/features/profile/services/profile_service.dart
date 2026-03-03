import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient: apiClient);
});

/// Service for profile-related API operations.
class ProfileService {
  final ApiClient apiClient;

  ProfileService({required this.apiClient});

  /// Get achievement points for the current user.
  Future<int> getAchievementPoints() async {
    final response = await apiClient.get(ApiConstants.achievements);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as int? ?? 0;
    }
    return 0;
  }

  /// Get user preferences.
  Future<Map<String, dynamic>> getUserPreferences() async {
    final response = await apiClient.get(ApiConstants.userPreferences);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return {};
  }

  /// Update user preferences.
  Future<Map<String, dynamic>> updateUserPreferences(
      Map<String, dynamic> preferences) async {
    final response =
        await apiClient.put(ApiConstants.userPreferences, data: preferences);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return {};
  }
}
