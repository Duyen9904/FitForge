import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/auth_repository.dart';
import '../services/profile_service.dart';

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileService = ref.watch(profileServiceProvider);
  return ProfileRepository(
    authRepository: authRepository,
    profileService: profileService,
  );
});

/// Repository for profile data. Combines auth (user data) with profile service (points, preferences).
class ProfileRepository {
  final AuthRepository _authRepository;
  final ProfileService _profileService;

  ProfileRepository({
    required AuthRepository authRepository,
    required ProfileService profileService,
  })  : _authRepository = authRepository,
        _profileService = profileService;

  /// Get current user profile.
  Future<UserModel> getCurrentUser() async {
    return _authRepository.getCurrentUser();
  }

  /// Get achievement points.
  Future<int> getAchievementPoints() async {
    try {
      return await _profileService.getAchievementPoints();
    } catch (_) {
      return 0;
    }
  }
}
