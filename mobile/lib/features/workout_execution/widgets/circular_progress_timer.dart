import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Circular countdown timer with a central PAUSE/PLAY icon button.
/// Shows reps count or seconds remaining inside the circle.
class CircularProgressTimer extends StatelessWidget {
  final int displayValue;
  final double progress; // 0.0 (empty) → 1.0 (full)
  final bool isPaused;
  final VoidCallback onTogglePause;
  final double size;
  final double strokeWidth;

  const CircularProgressTimer({
    super.key,
    required this.displayValue,
    required this.progress,
    required this.isPaused,
    required this.onTogglePause,
    this.size = 180,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          activeColor: AppColors.white,
          backgroundColor: AppColors.white.withOpacity(0.25),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reps / seconds value
              Text(
                '$displayValue',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      height: 1.0,
                    ),
              ),
              const SizedBox(height: 4),
              // Pause / Play button
              GestureDetector(
                onTap: onTogglePause,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: AppColors.white,
                    size: size * 0.12,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PAUSE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;

  _CircularProgressPainter({
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
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
