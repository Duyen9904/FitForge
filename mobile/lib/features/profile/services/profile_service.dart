import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient: apiClient);
});

/// Service for profile API operations. Stub for later (e.g. PATCH /users/me).
class ProfileService {
  final ApiClient apiClient;

  ProfileService({required this.apiClient});
}
