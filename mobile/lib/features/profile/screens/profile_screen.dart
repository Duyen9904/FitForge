import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/weekly_stats_section.dart';
import '../widgets/profile_trainings_section.dart';

/// Profile screen — redesigned to match the reference UI:
/// ProfileHeader → Statistics → Trainings
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(profileViewModelProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: profileState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => _buildErrorView(message, theme),
        loaded: (user, achievementPoints, activePlans) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(profileViewModelProvider.notifier).loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Header ──
                    ProfileHeader(
                      displayName: user.displayName,
                      email: user.email,
                      profileImageUrl: user.profileImageUrl,
                      memberSince: user.dateJoined,
                      achievementPoints: achievementPoints,
                      fitnessLevel: user.fitnessLevel,
                      primaryGoal: user.primaryGoalName,
                      onSettings: () => context.push(Routes.settings),
                    ),

                    const SizedBox(height: AppDimensions.spacing16),

                    // ── Divider ──
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outlineVariant
                          .withOpacity(0.3),
                      indent: AppDimensions.spacing20,
                      endIndent: AppDimensions.spacing20,
                    ),

                    const SizedBox(height: AppDimensions.spacing24),

                    // ── Statistics Section ──
                    const WeeklyStatsSection(),

                    const SizedBox(height: AppDimensions.spacing32),

                    // ── Trainings Section ──
                    ProfileTrainingsSection(
                      plans: activePlans,
                      onShowAll: () =>
                          context.go(Routes.workouts),
                      onPlanTap: (planId) => context
                          .push(Routes.workoutPlanDetail(planId)),
                    ),

                    const SizedBox(height: AppDimensions.spacing48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Failed to load profile',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(profileViewModelProvider.notifier).loadProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
