import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Profile header matching the reference UI:
/// – Avatar on the left, name + stats on the right (horizontal row)
/// – Two stat counters (Current Weight & Target Weight) with horizontal spacing
/// – Fitness level badge (green dot) on the left
class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final DateTime? memberSince;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final String? fitnessLevel;
  final String? primaryGoal;
  final VoidCallback? onAvatarTap;
  final bool isUploadingAvatar;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    this.memberSince,
    this.currentWeightKg,
    this.targetWeightKg,
    this.fitnessLevel,
    this.primaryGoal,
    this.onAvatarTap,
    this.isUploadingAvatar = false,
  });



  String _formatWeight(double? weight) {
    if (weight == null) return '--';
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toStringAsFixed(1);
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
          const SizedBox(height: AppDimensions.spacing16),

          // ── Avatar (left) + Name & Stats (right) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar on the left
              _buildAvatar(theme),

              const SizedBox(width: AppDimensions.spacing16),

              // Name + stats column on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + Fitness level chip ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (fitnessLevel != null && fitnessLevel!.isNotEmpty) ...[
                          const SizedBox(width: AppDimensions.spacing6),
                          Chip(
                            label: Text(fitnessLevel!),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                            backgroundColor:
                                AppColors.success.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing4,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing8),

                    // ── Stats row (Current Weight & Target Weight) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _StatCounter(
                          value: '${_formatWeight(currentWeightKg)} kg',
                          label: 'Current',
                          theme: theme,
                        ),
                        const SizedBox(width: AppDimensions.spacing24),
                        _StatCounter(
                          value: '${_formatWeight(targetWeightKg)} kg',
                          label: 'Target',
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: isUploadingAvatar ? null : onAvatarTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          // Loading overlay
          if (isUploadingAvatar)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          // Camera icon overlay
          else
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact stat counter (value + label stacked vertically, centered).
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
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}