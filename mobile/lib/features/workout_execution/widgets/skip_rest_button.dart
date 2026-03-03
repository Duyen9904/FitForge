import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Full-width "Skip Rest" button with double-chevron icon and subtle shimmer pulse.
class SkipRestButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const SkipRestButton({
    super.key,
    this.onPressed,
  });

  @override
  State<SkipRestButton> createState() => _SkipRestButtonState();
}

class _SkipRestButtonState extends State<SkipRestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing40,
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final opacity = 0.15 + (_pulseController.value * 0.15);
            return SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightLarge,
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white.withValues(alpha: opacity),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                    side: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Skip Rest',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(width: AppDimensions.spacing8),
                    const Icon(
                      Icons.double_arrow_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
