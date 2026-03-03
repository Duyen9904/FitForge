import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// A row of 3 stat items showing workout summary (exercises, calories, minutes).
/// Features animated count-up numbers, icons, and glassmorphic container.
class WorkoutStatsRow extends StatelessWidget {
  final int exercises;
  final int calories;
  final int minutes;

  const WorkoutStatsRow({
    super.key,
    required this.exercises,
    required this.calories,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing24,
              horizontal: AppDimensions.spacing16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedStatItem(
                  icon: Icons.fitness_center_rounded,
                  value: exercises,
                  label: 'Exercises',
                  delay: 0,
                ),
                _buildDivider(),
                _AnimatedStatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: calories,
                  label: 'Calories',
                  delay: 200,
                ),
                _buildDivider(),
                _AnimatedStatItem(
                  icon: Icons.timer_outlined,
                  value: minutes,
                  label: 'Minutes',
                  delay: 400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.white.withValues(alpha: 0.2),
    );
  }
}

class _AnimatedStatItem extends StatefulWidget {
  final IconData icon;
  final int value;
  final String label;
  final int delay;

  const _AnimatedStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.delay,
  });

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: 0.15),
          ),
          child: Icon(
            widget.icon,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        // Animated count-up value
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: _animate ? widget.value : 0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, val, _) {
            return Text(
              '$val',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
            );
          },
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
