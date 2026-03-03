import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../repositories/profile_repository.dart';
import 'profile_state.dart';

/// Provider for ProfileViewModel
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref);
});

/// ViewModel for profile screen. Loads user data + achievement points.
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileViewModel(this._ref) : super(const ProfileState.initial());

  /// Load profile data: user model + achievement points.
  Future<void> loadProfile() async {
    state = const ProfileState.loading();
    try {
      final repo = _ref.read(profileRepositoryProvider);
      final results = await Future.wait([
        repo.getCurrentUser(),
        repo.getAchievementPoints(),
      ]);
      final user = results[0] as dynamic;
      final points = results[1] as int;
      state = ProfileState.loaded(user: user, achievementPoints: points);
    } catch (e) {
      state = ProfileState.error(e.toString());
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
