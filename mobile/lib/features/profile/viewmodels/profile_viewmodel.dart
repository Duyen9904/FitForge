import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/profile_models.dart';
import '../repositories/profile_repository.dart';
import 'profile_state.dart';

/// Provider for ProfileViewModel
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref);
});

/// ViewModel for profile screen. Loads user data + achievement points + profile summary.
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileViewModel(this._ref) : super(const ProfileState.initial());

  /// Load profile data: user model + achievement points + profile summary.
  Future<void> loadProfile() async {
    state = const ProfileState.loading();
    try {
      final repo = _ref.read(profileRepositoryProvider);

      final results = await Future.wait([
        repo.getCurrentUser(),
        repo.getAchievementPoints(),
        repo.getProfileSummary(),
      ]);

      final user = results[0] as dynamic;
      final points = results[1] as int;
      final profileSummary = results[2] as ProfileSummaryResponse?;

      state = ProfileState.loaded(
        user: user,
        achievementPoints: points,
        profileSummary: profileSummary,
      );
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }

  /// Upload a new avatar image.
  ///
  /// Returns `true` on success, `false` on failure.
  /// Updates the user in the loaded state with the new profileImageUrl.
  Future<bool> uploadAvatar(File imageFile) async {
    final currentState = state;
    if (currentState is! ProfileStateLoaded) return false;

    // Set uploading flag
    state = ProfileState.loaded(
      user: currentState.user,
      achievementPoints: currentState.achievementPoints,
      profileSummary: currentState.profileSummary,
      isUploadingAvatar: true,
    );

    try {
      final repo = _ref.read(profileRepositoryProvider);
      final updatedUser = await repo.uploadAvatar(imageFile);

      state = ProfileState.loaded(
        user: updatedUser,
        achievementPoints: currentState.achievementPoints,
        profileSummary: currentState.profileSummary,
      );
      return true;
    } catch (e) {
      // Restore previous state without uploading flag
      state = ProfileState.loaded(
        user: currentState.user,
        achievementPoints: currentState.achievementPoints,
        profileSummary: currentState.profileSummary,
      );
      return false;
    }
  }

  /// Logout: delegates to auth.
  Future<void> logout() async {
    final authState = _ref.read(authViewModelProvider);
    final email = authState.maybeWhen(
      authenticated: (user) => user.email,
      orElse: () => null,
    );
    await _ref.read(authViewModelProvider.notifier).logout(email ?? '');
  }
}
