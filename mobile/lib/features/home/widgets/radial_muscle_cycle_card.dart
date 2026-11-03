import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../ui/core/cards/app_cards.dart';
import '../../../ui/core/chips/app_chips.dart';
import '../models/muscle_cycle_models.dart';

/// Standalone card wrapper for the Radial Muscle Cycle
class RadialMuscleCycleCard extends StatelessWidget {
  final List<MuscleCycleDay> days;
  final int selectedDayIndex;
  final MuscleCycleScope scope;
  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<MuscleCycleScope> onScopeChanged;
  final ValueChanged<int> onWeekSelected;

  const RadialMuscleCycleCard({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.scope,
    this.selectedWeek = 2,
    this.totalWeeks = 4,
    required this.onDaySelected,
    required this.onScopeChanged,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppDarkHeroCard(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: RadialMuscleCycleSection(
        days: days,
        selectedDayIndex: selectedDayIndex,
        scope: scope,
        selectedWeek: selectedWeek,
        totalWeeks: totalWeeks,
        onDaySelected: onDaySelected,
        onScopeChanged: onScopeChanged,
        onWeekSelected: onWeekSelected,
      ),
    );
  }
}

/// Embeddable Radial Node Cycle extension section used inside `TodayActivitiesHeroCard`
/// or `RadialMuscleCycleCard` for previewing Weekly (7-day split) and Monthly (4-week) muscle focus cycles.
class RadialMuscleCycleSection extends StatelessWidget {
  final List<MuscleCycleDay> days;
  final int selectedDayIndex;
  final MuscleCycleScope scope;
  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<MuscleCycleScope> onScopeChanged;
  final ValueChanged<int> onWeekSelected;

  const RadialMuscleCycleSection({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.scope,
    this.selectedWeek = 2,
    this.totalWeeks = 4,
    required this.onDaySelected,
    required this.onScopeChanged,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = selectedDayIndex.clamp(0, days.length - 1);
    final selectedDay = days[safeIndex];
    final isMonth = scope == MuscleCycleScope.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Subheader Row: Cycle Scope Label on left, Week/Month Segmented Control on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isMonth
                    ? 'Month Cycle · Week $selectedWeek of $totalWeeks'
                    : '7-Day Split · Day ${selectedDay.dayNumber} (${selectedDay.shortWeekday})',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            AppSegmentedControl<MuscleCycleScope>(
              isDarkSurface: true,
              selectedValue: scope,
              segments: const {
                MuscleCycleScope.week: 'Week',
                MuscleCycleScope.month: 'Month',
              },
              onValueChanged: onScopeChanged,
            ),
          ],
        ),

        // 2. Month Week Selector Bar (Shown in Month Mode)
        AnimatedCrossFade(
          firstChild: const SizedBox(height: AppDimensions.spacing12),
          secondChild: Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacing12,
              bottom: AppDimensions.spacing12,
            ),
            child: Row(
              children: List.generate(totalWeeks, (index) {
                final wk = index + 1;
                final isCurrentWk = wk == selectedWeek;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < totalWeeks - 1 ? AppDimensions.spacing6 : 0,
                    ),
                    child: AppSelectablePill(
                      label: 'W$wk',
                      trailingText:
                          wk < 2 ? 'Done' : (wk == 2 ? 'Now' : 'Plan'),
                      isSelected: isCurrentWk,
                      isDarkSurface: true,
                      onTap: () => onWeekSelected(wk),
                    ),
                  ),
                );
              }),
            ),
          ),
          crossFadeState:
              isMonth ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),

        // 3. Radial Node Cycle Wheel + Right Interactive Legend
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Interactive Radial Node Cycle Wheel
            _RadialNodeCycleWheel(
              days: days,
              selectedIndex: safeIndex,
              isMonth: isMonth,
              selectedWeek: selectedWeek,
              totalWeeks: totalWeeks,
              onNodeTap: onDaySelected,
            ),

            const SizedBox(width: AppDimensions.spacing12),

            // Right: Interactive Day / Muscle Group Pills
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(days.length, (index) {
                  final day = days[index];
                  final isSelected = index == safeIndex;
                  final trailing = isMonth
                      ? '${day.monthlyPercentage}%'
                      : (day.isCompleted ? '✓' : day.shortWeekday);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index < days.length - 1 ? AppDimensions.spacing4 : 0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppSelectablePill(
                        label: 'D${day.dayNumber}: ${day.shortLabel}',
                        trailingText: trailing,
                        indicatorColor: day.nodeColor,
                        isSelected: isSelected,
                        isDarkSurface: true,
                        onTap: () => onDaySelected(index),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacing12),

        // 4. Selected Day Focus Tagline & Exercise Count Chip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${selectedDay.dayNumber} · ${selectedDay.muscleGroup}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacing2),
                  Text(
                    selectedDay.tagline,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryLight,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            AppBadgeChip(
              label: '${selectedDay.exercises.length} Exercises',
              icon: Icons.fitness_center_rounded,
              foregroundColor: AppColors.primaryLight,
              backgroundColor: AppColors.primary.withOpacity(0.22),
              borderColor: AppColors.primaryLight.withOpacity(0.35),
            ),
          ],
        ),
      ],
    );
  }
}

/// Interactive Radial Node Cycle widget with 7 circular nodes placed on a polar orbit
class _RadialNodeCycleWheel extends StatelessWidget {
  final List<MuscleCycleDay> days;
  final int selectedIndex;
  final bool isMonth;
  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int> onNodeTap;

  const _RadialNodeCycleWheel({
    required this.days,
    required this.selectedIndex,
    required this.isMonth,
    required this.selectedWeek,
    required this.totalWeeks,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    const double wheelSize = 168.0;
    const double center = wheelSize / 2;
    const double orbitRadius = 58.0;
    final selectedDay = days[selectedIndex];

    return SizedBox(
      width: wheelSize,
      height: wheelSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbit Ring & Month Macro Arcs Painter
          CustomPaint(
            size: const Size(wheelSize, wheelSize),
            painter: _RadialCycleOrbitPainter(
              nodeCount: days.length,
              selectedIndex: selectedIndex,
              orbitRadius: orbitRadius,
              activeColor: selectedDay.nodeColor,
              isMonth: isMonth,
              selectedWeek: selectedWeek,
              totalWeeks: totalWeeks,
            ),
          ),

          // Center Hub Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing6,
                    vertical: AppDimensions.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.22),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    'D${selectedDay.dayNumber} · ${selectedDay.shortWeekday}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  selectedDay.shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                if (isMonth) ...[
                  const SizedBox(height: AppDimensions.spacing2),
                  Text(
                    '${selectedDay.monthlyPercentage}% Month',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.grey400,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 7 Interactive Radial Day Nodes around the Orbit
          ...List.generate(days.length, (index) {
            final day = days[index];
            final isSelected = index == selectedIndex;
            final angleRad =
                (index * (2 * math.pi / days.length)) - (math.pi / 2);
            final nodeRadius = isSelected ? 18.0 : 14.0;
            final dx = center + orbitRadius * math.cos(angleRad) - nodeRadius;
            final dy = center + orbitRadius * math.sin(angleRad) - nodeRadius;

            return Positioned(
              left: dx,
              top: dy,
              child: GestureDetector(
                onTap: () => onNodeTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: nodeRadius * 2,
                  height: nodeRadius * 2,
                  decoration: BoxDecoration(
                    color: day.nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.surfaceDark.withOpacity(0.6),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: day.nodeColor.withOpacity(0.55),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'D${day.dayNumber}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? 11 : 10,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// CustomPainter that draws the dashed radial cycle orbit, active progress arc,
/// and outer 4-week macro cycle segments when in Month mode.
class _RadialCycleOrbitPainter extends CustomPainter {
  final int nodeCount;
  final int selectedIndex;
  final double orbitRadius;
  final Color activeColor;
  final bool isMonth;
  final int selectedWeek;
  final int totalWeeks;

  _RadialCycleOrbitPainter({
    required this.nodeCount,
    required this.selectedIndex,
    required this.orbitRadius,
    required this.activeColor,
    required this.isMonth,
    required this.selectedWeek,
    required this.totalWeeks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Optional Outer 4-Week Macro Ring in Month Mode
    if (isMonth && totalWeeks > 0) {
      final outerRadius = orbitRadius + 21;
      final weekSweep = (2 * math.pi) / totalWeeks;
      const gap = 0.12;

      for (int w = 0; w < totalWeeks; w++) {
        final isSelectedWk = (w + 1) == selectedWeek;
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelectedWk ? 4.0 : 2.5
          ..strokeCap = StrokeCap.round
          ..color = isSelectedWk
              ? AppColors.primaryLight
              : AppColors.white.withOpacity(0.14);

        final startAngle = -math.pi / 2 + (w * weekSweep) + (gap / 2);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          weekSweep - gap,
          false,
          paint,
        );
      }
    }

    // 2. Dashed Orbit Circle
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = AppColors.white.withOpacity(0.16);

    const int dashCount = 36;
    const double dashSweep = (2 * math.pi) / (dashCount * 2);
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashSweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: orbitRadius),
        startAngle,
        dashSweep,
        false,
        orbitPaint,
      );
    }

    // 3. Active Cycle Arc from Day 1 to Selected Day Node
    if (selectedIndex > 0 && nodeCount > 0) {
      final activeSweep = (selectedIndex / nodeCount) * 2 * math.pi;
      final activeArcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..color = activeColor.withOpacity(0.65);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: orbitRadius),
        -math.pi / 2,
        activeSweep,
        false,
        activeArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialCycleOrbitPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.isMonth != isMonth ||
        oldDelegate.selectedWeek != selectedWeek;
  }
}
