import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Circular countdown timer with gradient arc, glow effect, and a central
/// PAUSE/RESUME icon button. Shows reps count or seconds remaining.
class CircularProgressTimer extends StatefulWidget {
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
    this.size = 200,
    this.strokeWidth = 12,
  });

  @override
  State<CircularProgressTimer> createState() => _CircularProgressTimerState();
}

class _CircularProgressTimerState extends State<CircularProgressTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPaused) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CircularProgressTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && !oldWidget.isPaused) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _GradientCircularPainter(
          progress: widget.progress,
          strokeWidth: widget.strokeWidth,
          gradientColors: const [
            AppColors.white,
            AppColors.accent,
          ],
          backgroundColor: AppColors.white.withValues(alpha: 0.15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Value display
              Text(
                '${widget.displayValue}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      height: 1.0,
                    ),
              ),
              const SizedBox(height: 6),
              // Pause / Resume button with pulse
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = widget.isPaused
                      ? 1.0 + (_pulseController.value * 0.15)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: widget.onTogglePause,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: AppColors.white,
                      size: widget.size * 0.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isPaused ? 'RESUME' : 'PAUSE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCircularPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientCircularPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
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

    // Glow effect
    final glowPaint = Paint()
      ..color = gradientColors.first.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);

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

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _GradientCircularPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
