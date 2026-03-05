import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Three macro chips (Protein / Carbs / Fat) with progress bars.
class MacroSummaryBar extends StatelessWidget {
  final double proteinConsumed;
  final double proteinTarget;
  final double carbsConsumed;
  final double carbsTarget;
  final double fatConsumed;
  final double fatTarget;

  const MacroSummaryBar({
    super.key,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroChip(
            label: 'Protein left',
            grams: (proteinTarget - proteinConsumed).clamp(0, proteinTarget),
            progress: proteinTarget > 0
                ? (proteinConsumed / proteinTarget).clamp(0.0, 1.0)
                : 0.0,
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: _MacroChip(
            label: 'Carbs left',
            grams: (carbsTarget - carbsConsumed).clamp(0, carbsTarget),
            progress: carbsTarget > 0
                ? (carbsConsumed / carbsTarget).clamp(0.0, 1.0)
                : 0.0,
            color: const Color(0xFFFFA726),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: _MacroChip(
            label: 'Fat left',
            grams: (fatTarget - fatConsumed).clamp(0, fatTarget),
            progress: fatTarget > 0
                ? (fatConsumed / fatTarget).clamp(0.0, 1.0)
                : 0.0,
            color: const Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double grams;
  final double progress;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.grams,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${grams.toStringAsFixed(0)}g',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grey500,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
