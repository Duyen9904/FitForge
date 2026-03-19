import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Circular countdown timer ring with gradient stroke and scale pulse
/// on the final 3 seconds. Displays remaining seconds + "seconds" label.
class CountdownTimerRing extends StatelessWidget {
  final int totalSeconds;
  final double progress; // 0.0 (empty) to 1.0 (full)
  final int displaySeconds;
  final double size;
  final double strokeWidth;

  const CountdownTimerRing({
    super.key,
    required this.totalSeconds,
    required this.progress,
    required this.displaySeconds,
    this.size = 240,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Scale pulse on final 3 seconds
    final isUrgent = displaySeconds <= 3 && displaySeconds > 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isUrgent ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GradientTimerRingPainter(
            progress: progress,
            strokeWidth: strokeWidth,
            gradientColors: const [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.accent,
            ],
            backgroundColor: AppColors.white.withValues(alpha: 0.15),
            isUrgent: isUrgent,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$displaySeconds',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: size * 0.32,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? AppColors.accent : AppColors.white,
                        height: 1.0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'seconds',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientTimerRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final bool isUrgent;

  _GradientTimerRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
    required this.isUrgent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Glow for urgency
    if (isUrgent) {
      final glowPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);
    }

    // Gradient arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: gradientColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _GradientTimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isUrgent != isUrgent;
  }
}
