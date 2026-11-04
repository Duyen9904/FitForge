import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../ui/core/cards/app_cards.dart';
import '../../../ui/core/chips/app_chips.dart';
import '../models/muscle_cycle_models.dart';

/// Standalone card wrapper for the Segmented Radial Muscle Cycle Wheel
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

/// Embeddable Segmented Donut Wheel section used inside `TodayActivitiesHeroCard`
/// or `RadialMuscleCycleCard` for previewing Weekly and Monthly muscle focus cycles.
///
/// Designed after the segmented workout schedule wheel:
/// - Full circular segmented sector wedges separated by clean dark radial gaps
/// - Upright underlined day header (`MON:`) + bold uppercase muscle group inside each wedge
/// - Central dark circular hub with fitness emblem and bold uppercase cycle title
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
                    : 'Weekly Split · Day ${selectedDay.dayNumber} (${selectedDay.shortWeekday})',
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
          firstChild: const SizedBox(height: AppDimensions.spacing14),
          secondChild: Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacing12,
              bottom: AppDimensions.spacing14,
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

        // 3. Full-Width Segmented Muscle Schedule Wheel (Donut Sector Chart)
        Center(
          child: _SegmentedMuscleCycleWheel(
            days: days,
            selectedIndex: safeIndex,
            isMonth: isMonth,
            selectedWeek: selectedWeek,
            totalWeeks: totalWeeks,
            onSliceTap: onDaySelected,
          ),
        ),

        const SizedBox(height: AppDimensions.spacing14),

        // 4. Selected Day Focus Tagline & Exercise Count Chip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${selectedDay.dayNumber} (${selectedDay.shortWeekday}) · ${selectedDay.muscleGroup}',
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

/// Interactive Segmented Donut Wheel displaying each day as an annular wedge slice
/// with underlined day header (`MON:`) and uppercase muscle focus text directly inside the slice,
/// plus a dark circular center hub with fitness emblem and schedule title.
class _SegmentedMuscleCycleWheel extends StatelessWidget {
  final List<MuscleCycleDay> days;
  final int selectedIndex;
  final bool isMonth;
  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int> onSliceTap;

  const _SegmentedMuscleCycleWheel({
    required this.days,
    required this.selectedIndex,
    required this.isMonth,
    required this.selectedWeek,
    required this.totalWeeks,
    required this.onSliceTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double wheelSize =
            math.min(constraints.maxWidth, 300.0).clamp(250.0, 300.0);
        final double center = wheelSize / 2;
        final double baseOuterRadius = (wheelSize / 2) - 8.0;
        final double innerRadius = baseOuterRadius * 0.40;
        final int count = days.length;
        final double sliceSweep = count > 0 ? (2 * math.pi) / count : 0;
        final selectedDay = days[selectedIndex];
        final activeDaysCount = days.where((d) => !d.isRestDay).length;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            if (count == 0) return;
            final dx = details.localPosition.dx - center;
            final dy = details.localPosition.dy - center;
            final dist = math.sqrt(dx * dx + dy * dy);

            if (dist >= innerRadius * 0.9 && dist <= baseOuterRadius + 10) {
              double angle = math.atan2(dy, dx) + (math.pi / 2);
              if (angle < 0) {
                angle += 2 * math.pi;
              }
              final tappedIdx =
                  (angle / sliceSweep).floor().clamp(0, count - 1);
              onSliceTap(tappedIdx);
            }
          },
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Segmented Wedge Slices, Radial Gap Dividers, and Dark Center Hub
                CustomPaint(
                  size: Size(wheelSize, wheelSize),
                  painter: _SegmentedCycleWheelPainter(
                    days: days,
                    selectedIndex: selectedIndex,
                    innerRadius: innerRadius,
                    baseOuterRadius: baseOuterRadius,
                    isMonth: isMonth,
                    selectedWeek: selectedWeek,
                    totalWeeks: totalWeeks,
                  ),
                ),

                // 2. Upright Day Header + Muscle Focus Labels Inside Each Wedge Slice
                ...List.generate(count, (index) {
                  final day = days[index];
                  final isSelected = index == selectedIndex;
                  final midAngle =
                      (-math.pi / 2) + ((index + 0.5) * sliceSweep);
                  final sliceOuter =
                      isSelected ? baseOuterRadius + 4.5 : baseOuterRadius;
                  final labelRadius =
                      innerRadius + (sliceOuter - innerRadius) * 0.54;

                  final labelWidth = wheelSize * 0.255;
                  final labelHeight = 46.0;
                  final dx = center +
                      labelRadius * math.cos(midAngle) -
                      (labelWidth / 2);
                  final dy = center +
                      labelRadius * math.sin(midAngle) -
                      (labelHeight / 2);

                  final dayHeader = isMonth
                      ? '${day.shortWeekday.toUpperCase()} · ${day.monthlyPercentage}%'
                      : '${day.shortWeekday.toUpperCase()}:';

                  return Positioned(
                    left: dx,
                    top: dy,
                    width: labelWidth,
                    height: labelHeight,
                    child: IgnorePointer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Underlined Day Header (e.g., "MON:" / "THỨ 2:")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 1.0),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.grey900,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  dayHeader,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.grey900,
                                    fontWeight: FontWeight.w900,
                                    fontSize: isSelected ? 10.5 : 9.8,
                                    letterSpacing: 0.2,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                              if (day.isCompleted) ...[
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 10,
                                  color: AppColors.primaryDark,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Bold Uppercase Muscle Focus Label (e.g., "CHEST – TRI")
                          Text(
                            day.shortLabel.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.grey900,
                              fontWeight: FontWeight.w800,
                              fontSize: isSelected ? 9.5 : 8.8,
                              letterSpacing: -0.1,
                              height: 1.08,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // 3. Center Dark Hub Content (Emblem + Bold Schedule Title)
                SizedBox(
                  width: innerRadius * 1.76,
                  height: innerRadius * 1.76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Fitness Emblem Badge
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.16),
                          border: Border.all(
                            color: AppColors.secondaryLight.withOpacity(0.55),
                            width: 1.2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 16,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Center Bold Schedule Title (Matching reference center typography)
                      Text(
                        isMonth ? 'MONTH CYCLE' : 'WORKOUT SPLIT',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isMonth
                            ? 'WEEK $selectedWeek / $totalWeeks'
                            : '${selectedDay.shortWeekday.toUpperCase()} · DAY ${selectedDay.dayNumber}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isMonth
                            ? '${selectedDay.monthlyPercentage}% FOCUS'
                            : '$activeDaysCount DAYS / WEEK',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accentLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.0,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter that draws the segmented donut slices, uniform straight dark radial gaps,
/// selected slice highlight arc, and dark circular center hub.
class _SegmentedCycleWheelPainter extends CustomPainter {
  final List<MuscleCycleDay> days;
  final int selectedIndex;
  final double innerRadius;
  final double baseOuterRadius;
  final bool isMonth;
  final int selectedWeek;
  final int totalWeeks;

  _SegmentedCycleWheelPainter({
    required this.days,
    required this.selectedIndex,
    required this.innerRadius,
    required this.baseOuterRadius,
    required this.isMonth,
    required this.selectedWeek,
    required this.totalWeeks,
  });

  /// Returns a cohesive soft pastel/gradient pair for each slice using AppColors tokens
  /// so that dark bold typography inside each wedge has crisp, high-contrast legibility.
  List<Color> _getSliceGradientColors(int index, MuscleCycleDay day, bool isSelected) {
    final palette = <List<Color>>[
      [
        Color.lerp(AppColors.primaryLight, AppColors.white, 0.38)!,
        Color.lerp(AppColors.secondaryLight, AppColors.white, 0.22)!,
      ],
      [
        Color.lerp(AppColors.accentLight, AppColors.white, 0.36)!,
        Color.lerp(AppColors.secondaryLight, AppColors.white, 0.30)!,
      ],
      [
        Color.lerp(AppColors.secondary, AppColors.white, 0.42)!,
        Color.lerp(AppColors.primaryLight, AppColors.white, 0.34)!,
      ],
      [
        Color.lerp(AppColors.warning, AppColors.white, 0.52)!,
        Color.lerp(AppColors.accentLight, AppColors.white, 0.40)!,
      ],
      [
        Color.lerp(AppColors.info, AppColors.white, 0.50)!,
        Color.lerp(AppColors.secondaryLight, AppColors.white, 0.32)!,
      ],
      [
        Color.lerp(AppColors.primary, AppColors.white, 0.46)!,
        Color.lerp(AppColors.accentLight, AppColors.white, 0.35)!,
      ],
      [
        Color.lerp(AppColors.grey300, AppColors.white, 0.35)!,
        Color.lerp(AppColors.secondaryLight, AppColors.white, 0.48)!,
      ],
    ];

    final basePair = palette[index % palette.length];
    if (isSelected) {
      return [
        Color.lerp(basePair[0], AppColors.white, 0.25)!,
        Color.lerp(basePair[1], day.nodeColor, 0.15)!,
      ];
    }
    return basePair;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final count = days.length;
    if (count == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final sliceSweep = (2 * math.pi) / count;
    const startOffset = -math.pi / 2;

    // 1. Draw Each Wedge Slice (Annular Sector)
    for (int i = 0; i < count; i++) {
      final day = days[i];
      final isSelected = i == selectedIndex;
      final outerR = isSelected ? baseOuterRadius + 4.5 : baseOuterRadius;
      final startAngle = startOffset + (i * sliceSweep);
      final midAngle = startAngle + (sliceSweep / 2);

      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerR),
          startAngle,
          sliceSweep,
          true,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + sliceSweep,
          -sliceSweep,
          false,
        )
        ..close();

      final gradientColors = _getSliceGradientColors(i, day, isSelected);
      final sliceOrigin = Offset(
        center.dx + innerRadius * math.cos(midAngle),
        center.dy + innerRadius * math.sin(midAngle),
      );
      final sliceEnd = Offset(
        center.dx + outerR * math.cos(midAngle),
        center.dy + outerR * math.sin(midAngle),
      );

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ).createShader(Rect.fromPoints(sliceOrigin, sliceEnd));

      canvas.drawPath(path, fillPaint);

      // Selected Slice Outer Accent Rim
      if (isSelected) {
        final highlightPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.butt
          ..color = AppColors.primaryLight;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerR + 1.5),
          startAngle + 0.03,
          sliceSweep - 0.06,
          false,
          highlightPaint,
        );
      }
    }

    // 2. Draw Straight Uniform Dark Radial Gap Dividers (Creates the exact separated wedge look)
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.square
      ..color = AppColors.surfaceDark;

    for (int i = 0; i < count; i++) {
      final angle = startOffset + (i * sliceSweep);
      final p1 = Offset(
        center.dx + (innerRadius - 2) * math.cos(angle),
        center.dy + (innerRadius - 2) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (baseOuterRadius + 7) * math.cos(angle),
        center.dy + (baseOuterRadius + 7) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, dividerPaint);
    }

    // 3. Draw Central Dark Circle Hub
    final centerHubPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.surfaceDark;
    canvas.drawCircle(center, innerRadius + 2.5, centerHubPaint);

    // Subtle Inner Hub Surface & Border Ring
    final innerCorePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.grey900.withOpacity(0.65);
    canvas.drawCircle(center, innerRadius - 1.5, innerCorePaint);

    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.secondaryLight.withOpacity(0.22);
    canvas.drawCircle(center, innerRadius - 4.0, innerRingPaint);
  }

  @override
  bool shouldRepaint(covariant _SegmentedCycleWheelPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isMonth != isMonth ||
        oldDelegate.selectedWeek != selectedWeek ||
        oldDelegate.days != days;
  }
}
