import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_models.dart';
import 'chart_metric_toggle.dart';
import 'chart_summary_row.dart';
import 'chart_empty_state.dart';

class WeeklyProgressChart extends StatefulWidget {
  final WeeklyWorkoutProgressResponse weeklyProgress;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyProgress,
  });

  @override
  State<WeeklyProgressChart> createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends State<WeeklyProgressChart> {
  ChartMetric _selectedMetric = ChartMetric.calories;

  bool get _hasAnyData {
    return widget.weeklyProgress.dailyData.any((d) =>
        d.caloriesBurned > 0 || d.minutesExercised > 0 || d.workoutsCompleted > 0);
  }

  /// A day is "missed" when the backend marks it as missed.
  bool _isDayMissed(DailyWorkoutData? day) {
    if (day == null) return false;
    return day.isMissed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacing16),

          // Metric Toggle
          ChartMetricToggle(
            selected: _selectedMetric,
            onChanged: (metric) => setState(() => _selectedMetric = metric),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Chart or Empty State
          if (_hasAnyData) ...[
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue() * 1.25,
                  barTouchData: _buildTouchData(),
                  titlesData: _buildTitlesData(),
                  gridData: _buildGridData(),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            // Weekly Summary
            _buildSummaryRow(),
          ] else
            const ChartEmptyState(),
        ],
      ),
    );
  }

  /// Header with icon + title + static week label
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing4,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Text(
            'This Week',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  /// Touch/tooltip data
  BarTouchData _buildTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 12,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final day = _getDayData(groupIndex);
          if (day == null) return null;

          final dayName = _dayLabels[groupIndex];
          final isMissed = _isDayMissed(day);
          return BarTooltipItem(
            '$dayName${isMissed ? ' · MISSED' : ''}\n',
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: '${day.caloriesBurned} cal · ${day.minutesExercised}m · ${day.workoutsCompleted} wkt',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Axis titles
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= _dayLabels.length) {
              return const SizedBox.shrink();
            }
            final day = _getDayData(index);
            final isToday = day?.isToday ?? false;
            final isMissed = _isDayMissed(day);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  color: isMissed
                      ? AppColors.error
                      : isToday
                          ? AppColors.primary
                          : AppColors.grey400,
                  fontSize: 11,
                  fontWeight: (isToday || isMissed) ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          },
          reservedSize: 28,
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Subtle horizontal grid lines at 33% and 66%
  FlGridData _buildGridData() {
    final maxVal = _getMaxValue();
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxVal > 0 ? maxVal / 3 : 100,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.grey100,
          strokeWidth: 1,
          dashArray: [4, 4],
        );
      },
    );
  }

  /// Build bar groups with gradient and pill shape
  List<BarChartGroupData> _buildBarGroups() {
    final List<BarChartGroupData> groups = [];
    final maxBg = _getMaxValue() * 1.15;

    for (int i = 0; i < 7; i++) {
      final day = _getDayData(i);
      final value = _getValueForMetric(day);
      final isToday = day?.isToday ?? false;
      final hasWorkout = (day?.workoutsCompleted ?? 0) > 0;
      final isMissed = _isDayMissed(day);

      // Determine bar colors
      LinearGradient gradient;
      if (isMissed) {
        // Missed day — red/error gradient
        gradient = LinearGradient(
          colors: [AppColors.error.withOpacity(0.6), AppColors.error],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      } else if (isToday && hasWorkout) {
        gradient = const LinearGradient(
          colors: [AppColors.accentLight, AppColors.accent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      } else if (isToday) {
        gradient = LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.4),
            AppColors.accent.withOpacity(0.6),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      } else if (hasWorkout) {
        gradient = const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      } else {
        gradient = LinearGradient(
          colors: [AppColors.grey200, AppColors.grey200],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isMissed && value == 0 ? maxBg * 0.12 : value,
              gradient: gradient,
              width: 18,
              borderRadius: BorderRadius.circular(9),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxBg,
                color: isMissed ? AppColors.error.withOpacity(0.06) : AppColors.grey50,
              ),
            ),
          ],
          showingTooltipIndicators: isToday && value > 0 ? [0] : [],
        ),
      );
    }
    return groups;
  }

  /// Summary row using WeeklySummary data
  Widget _buildSummaryRow() {
    final summary = widget.weeklyProgress.summary;
    final totalWorkoutsPlanned = widget.weeklyProgress.dailyData.length;

    return ChartSummaryRow(
      totalCalories: summary?.totalCaloriesBurned ?? 0,
      totalMinutes: summary?.totalMinutesExercised ?? 0,
      workoutsCompleted: summary?.totalWorkoutsCompleted ?? 0,
      workoutsPlanned: totalWorkoutsPlanned,
    );
  }

  // ─── Helpers ──────────────────────────────────────────

  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  DailyWorkoutData? _getDayData(int index) {
    final data = widget.weeklyProgress.dailyData;
    if (data.isEmpty || index >= data.length) return null;
    return data[index];
  }

  double _getValueForMetric(DailyWorkoutData? day) {
    if (day == null) return 0;
    switch (_selectedMetric) {
      case ChartMetric.calories:
        return day.caloriesBurned.toDouble();
      case ChartMetric.duration:
        return day.minutesExercised.toDouble();
      case ChartMetric.workouts:
        return day.workoutsCompleted.toDouble();
    }
  }

  double _getMaxValue() {
    if (widget.weeklyProgress.dailyData.isEmpty) return 100;
    final values = widget.weeklyProgress.dailyData.map(
      (d) => _getValueForMetric(d),
    );
    final max = values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? (_selectedMetric == ChartMetric.workouts ? 5 : 500) : max;
  }
}
