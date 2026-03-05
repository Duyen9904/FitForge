import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../profile/widgets/profile_menu_tile.dart';
import '../../profile/widgets/profile_section_header.dart';

/// Consolidated settings screen with grouped list tiles:
/// Preferences, Account & Security, About & Support, and Log Out.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loading = true;
  String _measurementUnit = 'METRIC';
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.userPreferences);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final prefs = data['data'] as Map<String, dynamic>;
        setState(() {
          _measurementUnit =
              (prefs['measurementUnit'] as String?) ?? 'METRIC';
          _notificationEnabled =
              (prefs['notificationEnabled'] as bool?) ?? true;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiConstants.userPreferences,
        data: {key: value},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // ── My Onboarding Data ──
                const ProfileSectionHeader(title: 'My Onboarding Data'),
                ProfileMenuTile(
                  icon: Icons.checklist,
                  iconColor: AppColors.primary,
                  title: 'Review My Setup Data',
                  subtitle: 'See your onboarding answers',
                  onTap: () => context.push(Routes.onboardingReview),
                ),

                // ── Training Preferences ──
                const ProfileSectionHeader(title: 'Training Preferences'),
                ProfileMenuTile(
                  icon: Icons.fitness_center,
                  iconColor: AppColors.accent,
                  title: 'Workout Preferences',
                  subtitle: 'Duration, time, reminders',
                  onTap: () => context.push(Routes.trainingPreferences),
                ),

                // ── Nutrition Targets ──
                const ProfileSectionHeader(title: 'Nutrition Targets'),
                ProfileMenuTile(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.error,
                  title: 'Calorie & Macro Targets',
                  subtitle: 'Daily calories, protein, carbs, fats',
                  onTap: () => context.push(Routes.nutritionTargets),
                ),

                // ── Achievements ──
                const ProfileSectionHeader(title: 'Achievements'),
                ProfileMenuTile(
                  icon: Icons.emoji_events,
                  iconColor: AppColors.warning,
                  title: 'Achievement Gallery',
                  subtitle: 'View your earned badges',
                  onTap: () {
                    // TODO: Navigate to achievement gallery
                  },
                ),

                // ── Preferences ──
                const ProfileSectionHeader(title: 'Preferences'),
                ProfileMenuTile(
                  icon: Icons.straighten,
                  iconColor: AppColors.grey500,
                  title: 'Units',
                  subtitle: _measurementUnit == 'METRIC'
                      ? 'Metric (kg, cm)'
                      : 'Imperial (lbs, ft)',
                  onTap: _showUnitPicker,
                ),
                ProfileMenuTile(
                  icon: Icons.dark_mode,
                  iconColor: AppColors.grey700,
                  title: 'Appearance',
                  subtitle: 'System default',
                  onTap: () {
                    // TODO: Implement theme selection
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.warning,
                  title: 'Notifications',
                  subtitle: _notificationEnabled ? 'On' : 'Off',
                  trailing: Switch.adaptive(
                    value: _notificationEnabled,
                    onChanged: (value) {
                      setState(() => _notificationEnabled = value);
                      _updatePreference('notificationEnabled', value);
                    },
                  ),
                  showChevron: false,
                ),

                // ── Account & Security ──
                const ProfileSectionHeader(title: 'Account & Security'),
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

                // ── About & Support ──
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
    );
  }

  void _showUnitPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Metric (kg, cm)'),
              value: 'METRIC',
              groupValue: _measurementUnit,
              onChanged: (value) {
                setState(() => _measurementUnit = value!);
                _updatePreference('measurementUnit', value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Imperial (lbs, ft)'),
              value: 'IMPERIAL',
              groupValue: _measurementUnit,
              onChanged: (value) {
                setState(() => _measurementUnit = value!);
                _updatePreference('measurementUnit', value);
                Navigator.pop(context);
              },
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
