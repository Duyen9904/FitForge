import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'profile_state.dart';

/// Provider for ProfileViewModel
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref);
});

/// ViewModel for profile. Delegates logout to AuthViewModel; extend for profile-specific state later.
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileViewModel(this._ref) : super(const ProfileState.initial());

  /// Logout: delegates to auth. Reads email from auth state and invokes AuthViewModel.logout(email).
  Future<void> logout() async {
    final authState = _ref.read(authViewModelProvider);
    final email = authState.maybeWhen(
      authenticated: (user) => user.email,
      orElse: () => null,
    );
    await _ref.read(authViewModelProvider.notifier).logout(email ?? '');
  }
}
