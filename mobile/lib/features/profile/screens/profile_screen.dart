import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_section_header.dart';
import '../widgets/profile_stats_card.dart';

/// Full profile & settings screen with all menu sections.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data on screen init
    Future.microtask(
        () => ref.read(profileViewModelProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: profileState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => _buildErrorView(message, theme),
        loaded: (user, achievementPoints) {
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
                    ),

                    // ── Fitness Stats Cards ──
                    _buildStatsCards(user, theme),

                    // ── Section A: My Fitness Profile ──
                    const ProfileSectionHeader(title: 'My Fitness Profile'),
                    ProfileMenuTile(
                      icon: Icons.straighten,
                      iconColor: AppColors.info,
                      title: 'Body Measurements',
                      subtitle: 'Weight, height, body composition',
                      onTap: () =>
                          context.push(Routes.recordMeasurement),
                    ),
                    ProfileMenuTile(
                      icon: Icons.flag_outlined,
                      iconColor: AppColors.success,
                      title: 'Fitness Goals',
                      subtitle: user.primaryGoalName ?? 'Set your goal',
                      onTap: () =>
                          context.push(Routes.fitnessGoals),
                    ),
                    ProfileMenuTile(
                      icon: Icons.trending_up,
                      iconColor: AppColors.warning,
                      title: 'Fitness Level',
                      subtitle: user.fitnessLevel ?? 'Not set',
                      showChevron: false,
                    ),

                    // ── Section B: My Onboarding Data ──
                    const ProfileSectionHeader(title: 'My Onboarding Data'),
                    ProfileMenuTile(
                      icon: Icons.checklist,
                      iconColor: AppColors.primary,
                      title: 'Review My Setup Data',
                      subtitle: 'See your onboarding answers',
                      onTap: () =>
                          context.push(Routes.onboardingReview),
                    ),

                    // ── Section C: Training Preferences ──
                    const ProfileSectionHeader(title: 'Training Preferences'),
                    ProfileMenuTile(
                      icon: Icons.fitness_center,
                      iconColor: AppColors.accent,
                      title: 'Workout Preferences',
                      subtitle: 'Duration, time, reminders',
                      onTap: () =>
                          context.push(Routes.trainingPreferences),
                    ),

                    // ── Section D: Nutrition Targets ──
                    const ProfileSectionHeader(title: 'Nutrition Targets'),
                    ProfileMenuTile(
                      icon: Icons.local_fire_department,
                      iconColor: AppColors.error,
                      title: 'Calorie & Macro Targets',
                      subtitle: 'Daily calories, protein, carbs, fats',
                      onTap: () =>
                          context.push(Routes.nutritionTargets),
                    ),

                    // ── Section E: App Settings ──
                    const ProfileSectionHeader(title: 'App Settings'),
                    ProfileMenuTile(
                      icon: Icons.straighten,
                      iconColor: AppColors.grey500,
                      title: 'Units',
                      subtitle: 'Metric / Imperial',
                      onTap: () =>
                          context.push(Routes.appSettings),
                    ),
                    ProfileMenuTile(
                      icon: Icons.dark_mode,
                      iconColor: AppColors.grey700,
                      title: 'Theme',
                      subtitle: 'Light / Dark / System',
                      onTap: () =>
                          context.push(Routes.appSettings),
                    ),
                    ProfileMenuTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      title: 'Notifications',
                      subtitle: 'Workout reminders & alerts',
                      onTap: () =>
                          context.push(Routes.appSettings),
                    ),

                    // ── Section F: Achievements ──
                    const ProfileSectionHeader(title: 'Achievements'),
                    ProfileMenuTile(
                      icon: Icons.emoji_events,
                      iconColor: AppColors.warning,
                      title: 'Achievement Gallery',
                      subtitle: '$achievementPoints points earned',
                      onTap: () {
                        // TODO: Navigate to achievement gallery
                      },
                    ),

                    // ── Section G: Account & Privacy (P2 — placeholder) ──
                    const ProfileSectionHeader(title: 'Account'),
                    ProfileMenuTile(
                      icon: Icons.lock_outline,
                      iconColor: AppColors.grey500,
                      title: 'Change Password',
                      subtitle: 'Coming soon',
                      showChevron: false,
                    ),
                    ProfileMenuTile(
                      icon: Icons.delete_forever,
                      title: 'Delete Account',
                      subtitle: 'Coming soon',
                      isDanger: true,
                      showChevron: false,
                    ),

                    // ── Section H: About & Support ──
                    const ProfileSectionHeader(title: 'About & Support'),
                    ProfileMenuTile(
                      icon: Icons.help_outline,
                      iconColor: AppColors.info,
                      title: 'Help & FAQ',
                      onTap: () {
                        // TODO: Open help
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.star_outline,
                      iconColor: AppColors.warning,
                      title: 'Rate Us',
                      onTap: () {
                        // TODO: Open store rating
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.description,
                      iconColor: AppColors.grey500,
                      title: 'Terms of Service',
                      onTap: () {
                        // TODO: Open terms
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.policy,
                      iconColor: AppColors.grey500,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.info_outline,
                      iconColor: AppColors.grey400,
                      title: 'App Version',
                      subtitle: 'v1.0.0',
                      showChevron: false,
                    ),

                    const SizedBox(height: AppDimensions.spacing24),

                    // ── Logout ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: const Text('Log Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacing12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusLarge),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildStatsCards(dynamic user, ThemeData theme) {
    final weightStr = user.currentWeightKg != null
        ? user.currentWeightKg!.toStringAsFixed(1)
        : '--';
    final targetStr = user.targetWeightKg != null
        ? user.targetWeightKg!.toStringAsFixed(1)
        : '--';
    final heightStr = user.heightCm != null
        ? user.heightCm!.toStringAsFixed(0)
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ProfileStatsCard(
              icon: Icons.monitor_weight_outlined,
              label: 'Current Weight',
              value: weightStr,
              unit: 'kg',
              color: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.spacing8),
            ProfileStatsCard(
              icon: Icons.gps_fixed,
              label: 'Target Weight',
              value: targetStr,
              unit: 'kg',
              color: AppColors.success,
            ),
            const SizedBox(width: AppDimensions.spacing8),
            ProfileStatsCard(
              icon: Icons.height,
              label: 'Height',
              value: heightStr,
              unit: 'cm',
              color: AppColors.info,
            ),
            const SizedBox(width: AppDimensions.spacing8),
            ProfileStatsCard(
              icon: Icons.fitness_center,
              label: 'Fitness Level',
              value: user.fitnessLevel ?? '--',
              color: AppColors.warning,
            ),
          ],
        ),
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(profileViewModelProvider.notifier).logout();
    }
  }
}
