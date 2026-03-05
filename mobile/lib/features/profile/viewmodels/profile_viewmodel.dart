import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../../workouts/services/workout_plan_service.dart';
import '../repositories/profile_repository.dart';
import 'profile_state.dart';

/// Provider for ProfileViewModel
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref);
});

/// ViewModel for profile screen. Loads user data + achievement points + active plans.
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileViewModel(this._ref) : super(const ProfileState.initial());

  /// Load profile data: user model + achievement points + active workout plans.
  Future<void> loadProfile() async {
    state = const ProfileState.loading();
    try {
      final repo = _ref.read(profileRepositoryProvider);
      final workoutService = _ref.read(workoutPlanServiceProvider);

      final results = await Future.wait([
        repo.getCurrentUser(),
        repo.getAchievementPoints(),
      ]);

      final user = results[0] as dynamic;
      final points = results[1] as int;

      // Fetch active plans separately (different return type)
      List<WorkoutPlanSummaryResponse> activePlans = [];
      try {
        final plansResponse =
            await workoutService.getActiveUserPlans(page: 0, size: 5);
        if (plansResponse.success && plansResponse.data != null) {
          activePlans = plansResponse.data!.content;
        }
      } catch (_) {
        // Silently fail - plans are optional
      }

      state = ProfileState.loaded(
        user: user,
        achievementPoints: points,
        activePlans: activePlans,
      );
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

