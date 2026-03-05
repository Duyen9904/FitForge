import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Redesigned profile header matching the reference UI:
/// – Circular avatar with gradient ring
/// – Name + stat counters (achievement pts, member days)
/// – Fitness level badge + primary goal chip
class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final DateTime? memberSince;
  final int achievementPoints;
  final String? fitnessLevel;
  final String? primaryGoal;
  final VoidCallback? onSettings;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    this.memberSince,
    this.achievementPoints = 0,
    this.fitnessLevel,
    this.primaryGoal,
    this.onSettings,
  });

  int get _memberDays {
    if (memberSince == null) return 0;
    return DateTime.now().difference(memberSince!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
      ),
      child: Column(
        children: [
          // ── Top action bar ──
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacing8,
              bottom: AppDimensions.spacing4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {},
                  iconSize: 22,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: onSettings,
                  iconSize: 22,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacing8),

          // ── Avatar + Info ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with gradient ring
              _buildAvatar(theme),

              const SizedBox(width: AppDimensions.spacing20),

              // Name + stat counters
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                    // Stat counters row
                    Row(
                      children: [
                        _StatCounter(
                          value: achievementPoints.toString(),
                          label: 'points',
                          theme: theme,
                        ),
                        const SizedBox(width: AppDimensions.spacing24),
                        _StatCounter(
                          value: _memberDays.toString(),
                          label: 'days',
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing16),

          // ── Badge row ──
          Row(
            children: [
              // Fitness level badge
              if (fitnessLevel != null && fitnessLevel!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        fitnessLevel!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (fitnessLevel != null && fitnessLevel!.isNotEmpty)
                const SizedBox(width: AppDimensions.spacing12),

              // Primary goal chip
              if (primaryGoal != null && primaryGoal!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Flexible(
                        child: Text(
                          primaryGoal!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing8),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
        ),
        child: CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary.withOpacity(0.12),
          backgroundImage:
              profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : null,
          child: profileImageUrl == null || profileImageUrl!.isEmpty
              ? Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Compact stat counter (value + label stacked vertically).
class _StatCounter extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCounter({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}