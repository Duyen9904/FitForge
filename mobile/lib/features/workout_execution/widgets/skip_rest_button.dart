import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Full-width "Skip Rest" button with a gradient or semi-transparent style.
class SkipRestButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SkipRestButton({
    super.key,
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
              backgroundColor: AppColors.white.withOpacity(0.2),
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusRound),
                side: BorderSide(
                  color: AppColors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              'Skip Rest',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
