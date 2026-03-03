import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Compact row showing weekly totals below the chart
class ChartSummaryRow extends StatelessWidget {
  final int totalCalories;
  final int totalMinutes;
  final int workoutsCompleted;
  final int workoutsPlanned;

  const ChartSummaryRow({
    super.key,
    this.totalCalories = 0,
    this.totalMinutes = 0,
    this.workoutsCompleted = 0,
    this.workoutsPlanned = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.accent,
            value: _formatCalories(totalCalories),
            label: 'cal',
          ),
          _divider(),
          _SummaryItem(
            icon: Icons.timer_outlined,
            iconColor: AppColors.info,
            value: _formatMinutes(totalMinutes),
            label: 'time',
          ),
          _divider(),
          _SummaryItem(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.primary,
            value: '$workoutsCompleted/$workoutsPlanned',
            label: 'done',
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.grey200,
    );
  }

  String _formatCalories(int cal) {
    if (cal >= 1000) return '${(cal / 1000).toStringAsFixed(1)}k';
    return cal.toString();
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '${h}h ${m}m';
    }
    return '${minutes}m';
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }
}
