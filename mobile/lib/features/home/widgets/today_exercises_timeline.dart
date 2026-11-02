import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Model representing an exercise display item on the daily timeline
class TimelineExerciseItem {
  final String startTime;
  final String endTime;
  final String title;
  final String category; // 'cardio', 'muscle', 'weight', or custom
  final String? targetMuscle; // e.g. 'Back', 'Chest', 'Legs', 'Full Body'
  final int currentStep;
  final int totalSteps;
  final String calories;
  final String heartRate;
  final String duration;
  final VoidCallback? onTap;

  const TimelineExerciseItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.category,
    this.targetMuscle,
    required this.currentStep,
    required this.totalSteps,
    required this.calories,
    required this.heartRate,
    required this.duration,
    this.onTap,
  });
}

/// Today's exercises timeline using app resource system colors:
/// - Timeline indicators in AppColors.primary
/// - Progress bars in AppColors.primary with system light backgrounds
/// - Muscle focus badges and metadata
class TodayExercisesTimeline extends StatelessWidget {
  final List<TimelineExerciseItem> items;
  final String? focusMuscleGroup;
  final VoidCallback? onGeneratePlan;
  final VoidCallback? onFilterTap;

  const TodayExercisesTimeline({
    super.key,
    required this.items,
    this.focusMuscleGroup,
    this.onGeneratePlan,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column Header: "Time" | "Exercise" + Muscle Focus badge | Sort Icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  'Time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Text(
                'Exercise',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (focusMuscleGroup != null && focusMuscleGroup!.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                    vertical: AppDimensions.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    focusMuscleGroup!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.grey600,
                  size: 20,
                ),
                onPressed: onFilterTap,
                tooltip: 'Filter exercises',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacing12),

        if (items.isEmpty)
          _buildEmptyState(context, theme)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return _buildTimelineRow(context, theme, item, isLast);
            },
          ),
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    ThemeData theme,
    TimelineExerciseItem item,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Time Column with Dot & Connector Line in AppColors.primary
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.startTime,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.endTime,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                // Timeline dot + line in system primary color
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: AppColors.primaryLight.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.spacing12),

          // 2. Right Exercise Card
          Expanded(
            child: _buildExerciseCard(context, theme, item),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ThemeData theme,
    TimelineExerciseItem item,
  ) {
    final progress = item.totalSteps > 0
        ? (item.currentStep / item.totalSteps).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Icon, Title + Target Muscle, and 3-dots Menu
                Row(
                  children: [
                    _buildCategoryIcon(item.category),
                    const SizedBox(width: AppDimensions.spacing10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                              fontSize: 16,
                            ),
                          ),
                          if (item.targetMuscle != null && item.targetMuscle!.isNotEmpty)
                            Text(
                              'Target: ${item.targetMuscle}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.grey500,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(
                          value: 'start',
                          child: Text('Start Workout'),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'details' || val == 'start') {
                          item.onTap?.call();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing12),

                // Progress Bar: "Exercise 4 of 6" using AppColors.primary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercise',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${item.currentStep} of ${item.totalSteps}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing14),

                // Metrics Row: Calories Burn | Heart Rate | Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol(theme, item.calories, 'Calories Burn'),
                    _buildStatCol(theme, item.heartRate, 'Heart Rate'),
                    _buildStatCol(theme, item.duration, 'Time'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (category.toLowerCase()) {
      case 'cardio':
        iconData = Icons.favorite_border_rounded;
        iconColor = AppColors.accent;
        bgColor = AppColors.accentLight.withOpacity(0.18);
        break;
      case 'muscle':
        iconData = Icons.fitness_center_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primaryLight.withOpacity(0.18);
        break;
      case 'weight':
        iconData = Icons.sports_gymnastics_rounded;
        iconColor = AppColors.secondaryDark;
        bgColor = AppColors.secondaryLight.withOpacity(0.25);
        break;
      default:
        iconData = Icons.fitness_center_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primaryLight.withOpacity(0.18);
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(iconData, size: 18, color: iconColor),
      ),
    );
  }

  Widget _buildStatCol(ThemeData theme, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.grey400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 48,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'No Workouts Scheduled',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing6),
          Text(
            'Rest day or no active workouts planned for this date.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          if (onGeneratePlan != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            ElevatedButton.icon(
              onPressed: onGeneratePlan,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generate Plan with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing20,
                  vertical: AppDimensions.spacing12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
