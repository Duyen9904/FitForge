import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_models.dart';

class WeeklyProgressChart extends StatelessWidget {
  final WeeklyWorkoutProgressResponse weeklyProgress;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyProgress,
  });

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
        children: [
          // Header: Calories label + Week dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(
                    'Calories',
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Week',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.grey600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing20),
          // Bar Chart
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxCalories() * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = weeklyProgress.dailyData.isNotEmpty &&
                              groupIndex < weeklyProgress.dailyData.length
                          ? weeklyProgress.dailyData[groupIndex]
                          : null;
                      return BarTooltipItem(
                        '${day?.caloriesBurned ?? 0} cal',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = weeklyProgress.dailyData.isNotEmpty &&
                            index < weeklyProgress.dailyData.length &&
                            weeklyProgress.dailyData[index].isToday;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.grey400,
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxCalories() {
    if (weeklyProgress.dailyData.isEmpty) return 500;
    final max = weeklyProgress.dailyData
        .map((d) => d.caloriesBurned.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return max == 0 ? 500 : max;
  }

  List<BarChartGroupData> _buildBarGroups() {
    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < 7; i++) {
      final data = weeklyProgress.dailyData.isNotEmpty &&
              i < weeklyProgress.dailyData.length
          ? weeklyProgress.dailyData[i]
          : null;
      final calories = data?.caloriesBurned.toDouble() ?? 0;
      final isToday = data?.isToday ?? false;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: calories,
              color: isToday ? AppColors.primary : AppColors.grey200,
              width: 28,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxCalories() * 1.1,
                color: AppColors.grey50,
              ),
            ),
          ],
          showingTooltipIndicators: isToday ? [0] : [],
        ),
      );
    }
    return groups;
  }
}
