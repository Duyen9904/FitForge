import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_dashboard_models.dart';

/// Horizontal scrollable section showing user's active workout plans
class ActivePlansSection extends StatelessWidget {
  final List<ActivePlanInfo> plans;
  final VoidCallback? onSeeAll;
  final void Function(int planId)? onPlanTap;

  const ActivePlansSection({
    super.key,
    required this.plans,
    this.onSeeAll,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Plans',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing12),

        // Horizontal plan cards
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.spacing12),
            itemBuilder: (context, index) {
              return _ActivePlanCard(
                plan: plans[index],
                onTap: () => onPlanTap?.call(plans[index].planId ?? 0),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  final ActivePlanInfo plan;
  final VoidCallback? onTap;

  const _ActivePlanCard({required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = plan.totalSessions > 0
        ? plan.sessionsCompleted / plan.totalSessions
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B55), Color(0xFF463F7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D2B55).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Plan name
            Text(
              plan.planName ?? 'Workout Plan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Plan info
            Text(
              '${plan.frequencyPerWeek ?? 0}x/week • ${plan.durationWeeks ?? 0} weeks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                  ),
            ),

            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Week ${plan.currentWeek}/${plan.durationWeeks ?? 0}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
