import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Bottom control bar with Previous, Stop, and Skip buttons.
class ExerciseControlButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onStop;
  final VoidCallback? onSkip;

  const ExerciseControlButtons({
    super.key,
    this.onPrevious,
    this.onStop,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing40,
        vertical: AppDimensions.spacing16,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: Icons.skip_previous_rounded,
              label: 'Previous',
              onTap: onPrevious,
            ),
            _ControlButton(
              icon: Icons.stop_rounded,
              label: 'Stop',
              onTap: onStop,
              isAccent: true,
            ),
            _ControlButton(
              icon: Icons.skip_next_rounded,
              label: 'Skip',
              onTap: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isAccent;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAccent
                  ? AppColors.white.withOpacity(0.25)
                  : AppColors.white.withOpacity(0.15),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
