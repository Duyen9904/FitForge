import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// "Back to Home" / "Next to Another Workout" button with celebration icon,
/// subtle gradient background, and arrow icon.
class NextWorkoutButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;

  const NextWorkoutButton({
    super.key,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing40,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLarge,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusRound),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  label ?? 'Next to Another Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(width: AppDimensions.spacing8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: AppDimensions.iconSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
