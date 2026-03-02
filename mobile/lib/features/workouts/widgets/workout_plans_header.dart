import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Gradient hero header for the Workout Plans screen.
/// Displays the title, active plan count, and an add button.
class WorkoutPlansHeader extends StatelessWidget {
  final int totalPlans;
  final int activePlans;
  final VoidCallback onAddPressed;

  const WorkoutPlansHeader({
    super.key,
    required this.totalPlans,
    required this.activePlans,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _buildStatBadge(
                        context,
                        icon: Icons.fitness_center_rounded,
                        label: '$totalPlans total',
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      _buildStatBadge(
                        context,
                        icon: Icons.bolt_rounded,
                        label: '$activePlans active',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'My Plans',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.white),
              onPressed: onAddPressed,
              tooltip: 'Create New Plan',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white),
          const SizedBox(width: AppDimensions.spacing6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
