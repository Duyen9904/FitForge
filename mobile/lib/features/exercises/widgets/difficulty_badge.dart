import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/difficulty_level.dart';

/// Badge widget to display difficulty level
class DifficultyBadge extends StatelessWidget {
  final String difficultyLevel;
  final bool compact;

  const DifficultyBadge({
    super.key,
    required this.difficultyLevel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final difficulty = DifficultyLevel.fromString(difficultyLevel) ??
        DifficultyLevel.beginner;
    final color = _getDifficultyColor(difficulty);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing8,
              vertical: AppDimensions.spacing4,
            )
          : const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing6,
            ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        difficulty.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 12,
            ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }
}
