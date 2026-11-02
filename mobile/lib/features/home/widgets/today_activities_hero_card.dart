import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_dashboard_models.dart';

/// Hero summary card using system resource colors:
/// - Dark slate container from AppColors.surfaceDark
/// - "Today's Activities" title
/// - Prominent target muscle group display (e.g. "Back", "Full Body", "Chest & Triceps")
/// - Circular progress ring in AppColors.primary ("7/9 Workout")
/// - Metrics row: "1200 kcal Calories Burned" | "90 bpm Heart Rate" | "03:00 hr Time"
class TodayActivitiesHeroCard extends StatelessWidget {
  final TodaySessionInfo? session;
  final WeeklyQuickStats? weeklyStats;
  final String? focusMuscleGroup;
  final VoidCallback? onTap;

  const TodayActivitiesHeroCard({
    super.key,
    this.session,
    this.weeklyStats,
    this.focusMuscleGroup,
    this.onTap,
  });

  /// Formats the targeted muscle display string
  String _formatTargetMuscle() {
    if (focusMuscleGroup != null && focusMuscleGroup!.isNotEmpty) {
      return focusMuscleGroup!;
    }
    if (session?.targetMuscleGroups.isNotEmpty ?? false) {
      return session!.targetMuscleGroups
          .map((m) => m[0].toUpperCase() + m.substring(1).toLowerCase())
          .join(' & ');
    }
    if (session?.sessionName != null && session!.sessionName!.isNotEmpty) {
      return session!.sessionName!;
    }
    return 'Back & Full Body';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetMuscle = _formatTargetMuscle();

    final caloriesText = weeklyStats != null && weeklyStats!.caloriesBurned > 0
        ? '${weeklyStats!.caloriesBurned} kcal'
        : '1200 kcal';

    final workoutsCompleted = weeklyStats?.workoutsCompleted ?? 7;
    final workoutsPlanned = weeklyStats?.workoutsPlanned ?? 9;
    final totalWorkouts = workoutsPlanned > 0 ? workoutsPlanned : 9;
    final progressValue = (workoutsCompleted / totalWorkouts).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radius24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Title & Focus Muscle on left, Circular Progress on right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's\nActivities",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing10),
                      // Prominent Target Muscle Focus Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing10,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fitness_center_rounded,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: AppDimensions.spacing6),
                            Flexible(
                              child: Text(
                                'Focus: $targetMuscle',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppDimensions.spacing12),

                // Circular Progress Indicator ("7/9 Workout") using AppColors.primary
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white.withOpacity(0.12),
                          ),
                        ),
                      ),
                      // Progress Arc in System Primary Color
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      // Inner Text: "7/9 Workout"
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$workoutsCompleted/$totalWorkouts',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Workout',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.grey400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacing20),

            // Subtle divider line
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),

            const SizedBox(height: AppDimensions.spacing16),

            // Bottom Metrics Row: Calories Burned | Heart Rate | Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  theme: theme,
                  value: caloriesText,
                  label: 'Calories Burned',
                ),
                _buildMetricItem(
                  theme: theme,
                  value: '90 bpm',
                  label: 'Heart Rate',
                ),
                _buildMetricItem(
                  theme: theme,
                  value: '03:00 hr',
                  label: 'Time',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required ThemeData theme,
    required String value,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.grey400,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
