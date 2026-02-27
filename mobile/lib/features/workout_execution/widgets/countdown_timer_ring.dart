import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Circular countdown timer ring widget.
/// Renders a purple arc that depletes as the countdown progresses,
/// with the remaining seconds number displayed in the center.
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
    this.size = 220,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TimerRingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          activeColor: AppColors.primary,
          backgroundColor: AppColors.grey200,
        ),
        child: Center(
          child: Text(
            '$displaySeconds',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Active arc
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
