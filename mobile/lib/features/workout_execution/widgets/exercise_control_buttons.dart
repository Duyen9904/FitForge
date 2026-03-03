import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Bottom control bar with Previous, Stop, and Skip buttons.
/// Includes scale-down press animation for tactile feedback and
/// a distinct red stop button.
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
              isStop: true,
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

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isStop;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isStop = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    final opacity = isDisabled ? 0.35 : 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isStop
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.white.withValues(alpha: 0.15),
                  border: isDisabled
                      ? null
                      : Border.all(
                          color: widget.isStop
                              ? AppColors.error.withValues(alpha: 0.5)
                              : AppColors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isStop
                      ? AppColors.error.withValues(alpha: 0.9)
                      : AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing6),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isStop
                          ? AppColors.error.withValues(alpha: 0.9)
                          : AppColors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
