import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/cards/app_cards.dart';
import '../../../ui/core/chips/app_chips.dart';
import '../models/home_dashboard_models.dart';
import '../models/muscle_cycle_models.dart';
import 'radial_muscle_cycle_card.dart';

/// Hero summary card using system resource colors:
/// - Keeps the original "Today's Activities" card (Title, Focus badge, 7/9 Workout ring, and bottom metrics row)
/// - Extends the card with an expandable Radial Node Muscle Cycle section (Week / Month muscle group focus cycle)
class TodayActivitiesHeroCard extends StatefulWidget {
  final TodaySessionInfo? session;
  final WeeklyQuickStats? weeklyStats;
  final String? focusMuscleGroup;
  final VoidCallback? onTap;

  // Extension properties for the Radial Muscle Focus Cycle
  final List<MuscleCycleDay>? cycleDays;
  final int selectedCycleIndex;
  final MuscleCycleScope cycleScope;
  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int>? onCycleDaySelected;
  final ValueChanged<MuscleCycleScope>? onCycleScopeChanged;
  final ValueChanged<int>? onWeekSelected;
  final bool initialCycleExpanded;

  const TodayActivitiesHeroCard({
    super.key,
    this.session,
    this.weeklyStats,
    this.focusMuscleGroup,
    this.onTap,
    this.cycleDays,
    this.selectedCycleIndex = 0,
    this.cycleScope = MuscleCycleScope.week,
    this.selectedWeek = 2,
    this.totalWeeks = 4,
    this.onCycleDaySelected,
    this.onCycleScopeChanged,
    this.onWeekSelected,
    this.initialCycleExpanded = true,
  });

  @override
  State<TodayActivitiesHeroCard> createState() =>
      _TodayActivitiesHeroCardState();
}

class _TodayActivitiesHeroCardState extends State<TodayActivitiesHeroCard> {
  late bool _isCycleExpanded;

  @override
  void initState() {
    super.initState();
    _isCycleExpanded = widget.initialCycleExpanded;
  }

  /// Formats the targeted muscle display string
  String _formatTargetMuscle() {
    if (widget.focusMuscleGroup != null &&
        widget.focusMuscleGroup!.isNotEmpty) {
      return widget.focusMuscleGroup!;
    }
    if (widget.session?.targetMuscleGroups.isNotEmpty ?? false) {
      return widget.session!.targetMuscleGroups
          .map((m) => m[0].toUpperCase() + m.substring(1).toLowerCase())
          .join(' & ');
    }
    if (widget.session?.sessionName != null &&
        widget.session!.sessionName!.isNotEmpty) {
      return widget.session!.sessionName!;
    }
    return 'Back & Full Body';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetMuscle = _formatTargetMuscle();

    final caloriesText =
        widget.weeklyStats != null && widget.weeklyStats!.caloriesBurned > 0
            ? '${widget.weeklyStats!.caloriesBurned} kcal'
            : '1200 kcal';

    final workoutsCompleted = widget.weeklyStats?.workoutsCompleted ?? 7;
    final workoutsPlanned = widget.weeklyStats?.workoutsPlanned ?? 9;
    final totalWorkouts = workoutsPlanned > 0 ? workoutsPlanned : 9;
    final progressValue = (workoutsCompleted / totalWorkouts).clamp(0.0, 1.0);

    final days = widget.cycleDays ??
        MuscleCycleDay.buildCycle(
          todaySession: widget.session,
          currentWeekday: DateTime.now().weekday,
          selectedWeek: widget.selectedWeek,
        );

    return AppDarkHeroCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Original Top Section: Title & Focus Muscle on left, Circular Progress on right
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
                    // Prominent Target Muscle Focus Badge (Using Reusable AppBadgeChip)
                    AppBadgeChip(
                      label: 'Focus: $targetMuscle',
                      icon: Icons.fitness_center_rounded,
                      foregroundColor: AppColors.primaryLight,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      borderColor: AppColors.primaryLight.withOpacity(0.35),
                      onTap: () {
                        setState(() {
                          _isCycleExpanded = !_isCycleExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacing12),

              // Original Circular Progress Indicator ("7/9 Workout") using AppColors.primary
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

          // 2. Original Bottom Metrics Row: Calories Burned | Heart Rate | Time
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

          const SizedBox(height: AppDimensions.spacing16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // 3. Extension Toggle Row for the Radial Muscle Focus Cycle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isCycleExpanded = !_isCycleExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacing6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        size: 14,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing8),
                    Text(
                      'Muscle Focus Cycle (Week / Month)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isCycleExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey400,
                  size: 20,
                ),
              ],
            ),
          ),

          // 4. Expandable Radial Node Muscle Cycle Extension Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacing14),
              child: RadialMuscleCycleSection(
                days: days,
                selectedDayIndex: widget.selectedCycleIndex,
                scope: widget.cycleScope,
                selectedWeek: widget.selectedWeek,
                totalWeeks: widget.totalWeeks,
                onDaySelected: widget.onCycleDaySelected ?? (_) {},
                onScopeChanged: widget.onCycleScopeChanged ?? (_) {},
                onWeekSelected: widget.onWeekSelected ?? (_) {},
              ),
            ),
            crossFadeState: _isCycleExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
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
