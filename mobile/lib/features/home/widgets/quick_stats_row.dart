import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_dashboard_models.dart';

/// Row of 3 compact stat pills showing weekly summary
class QuickStatsRow extends StatelessWidget {
  final WeeklyQuickStats? stats;

  const QuickStatsRow({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.error,
            iconBgColor: AppColors.error.withOpacity(0.1),
            value: _formatNumber(stats?.caloriesBurned ?? 0),
            label: 'cal',
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: _StatPill(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primary.withOpacity(0.1),
            value: '${stats?.workoutsCompleted ?? 0}/${stats?.workoutsPlanned ?? 0}',
            label: 'workouts',
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: _StatPill(
            icon: Icons.timer_outlined,
            iconColor: AppColors.info,
            iconBgColor: AppColors.info.withOpacity(0.1),
            value: _formatMinutes(stats?.totalMinutes ?? 0),
            label: 'time',
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m';
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey400,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
