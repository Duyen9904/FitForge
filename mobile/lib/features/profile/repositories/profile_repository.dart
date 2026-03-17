import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/profile_models.dart';
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

  /// Upload a new avatar image. Returns the updated user model.
  Future<UserModel> uploadAvatar(File imageFile) async {
    return _profileService.uploadAvatar(imageFile);
  }

  /// Get achievement points.
  Future<int> getAchievementPoints() async {
    try {
      return await _profileService.getAchievementPoints();
    } catch (_) {
      return 0;
    }
  }

  /// Get unified profile summary (heatmap + photos).
  Future<ProfileSummaryResponse?> getProfileSummary({int months = 6}) async {
    try {
      return await _profileService.getProfileSummary(months: months);
    } catch (_) {
      return null;
    }
  }
}
