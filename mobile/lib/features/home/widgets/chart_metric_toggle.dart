import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// The metric types that can be displayed in the chart
enum ChartMetric { calories, duration, workouts }

/// Segmented pill toggle for switching chart metrics
class ChartMetricToggle extends StatelessWidget {
  final ChartMetric selected;
  final ValueChanged<ChartMetric> onChanged;

  const ChartMetricToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartMetric.values.map((metric) {
          final isSelected = metric == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(metric),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _label(metric),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? AppColors.primary : AppColors.grey400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.calories:
        return 'Calories';
      case ChartMetric.duration:
        return 'Duration';
      case ChartMetric.workouts:
        return 'Workouts';
    }
  }
}
