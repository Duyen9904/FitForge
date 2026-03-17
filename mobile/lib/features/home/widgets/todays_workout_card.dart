import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_dashboard_models.dart';

/// Hero card showing today's scheduled workout session.
///
/// Three visual states:
/// 1. **No plans** → Generate Plan CTA (accent gradient)
/// 2. **Rest day / completed** → Rest Day / Completed card
/// 3. **Active session** → Progress card with circular indicator (reference design)
class TodaysWorkoutCard extends StatelessWidget {
  final TodaySessionInfo? session;
  final bool hasPlans;
  final double progress;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onGeneratePlan;

  const TodaysWorkoutCard({
    super.key,
    this.session,
    this.hasPlans = false,
    this.progress = 0.0,
    this.onStartWorkout,
    this.onGeneratePlan,
  });

  @override
  Widget build(BuildContext context) {
    // No plans at all → Generate Plan CTA
    if (!hasPlans) {
      return _buildGeneratePlanCard(context);
    }

    // Has plans but session is null or already completed → Rest Day
    if (session == null || session!.alreadyCompleted) {
      return _buildRestDayCard(context);
    }

    // Active session today
    return _buildActiveSessionCard(context);
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVE SESSION — new reference-image design
  // ─────────────────────────────────────────────────────────────

  Widget _buildActiveSessionCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? theme.colorScheme.surface : AppColors.grey50;
    final textColor = theme.colorScheme.onSurface;

    // Derive readable values from session data
    final category = session!.targetMuscleGroups.isNotEmpty
        ? session!.targetMuscleGroups.first
        : null;
    final workoutName = session!.sessionName ?? 'Workout Session';
    final durationLabel = _formatDuration(session!.estimatedMinutes ?? 0);
    final progressPercent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top content row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Progress" label + three-dots menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.more_vert_rounded,
                          size: AppDimensions.iconSmall,
                          color: AppColors.grey400,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacing8),

                    // Category chip
                    if (category != null) ...[
                      _CategoryChip(label: category, theme: theme),
                      const SizedBox(height: AppDimensions.spacing6),
                    ],

                    // Workout name
                    Text(
                      workoutName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),

                    // Duration + difficulty row
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          durationLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing12),
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          '${session!.exerciseCount ?? 0} exercises',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacing12),

              // Right: circular progress on green background
              _ProgressBlock(
                progress: progress,
                percent: progressPercent,
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing16),

          // ── Continue button ──
          _ContinueButton(
            onTap: onStartWorkout,
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Convert minutes into a human-friendly label.
  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '${hours}h ${remaining}m';
  }

  // ─────────────────────────────────────────────────────────────
  // REST DAY / COMPLETED (unchanged)
  // ─────────────────────────────────────────────────────────────

  Widget _buildRestDayCard(BuildContext context) {
    final isCompleted = session?.alreadyCompleted ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.self_improvement_rounded,
            size: 48,
            color: isCompleted ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            isCompleted ? 'Workout Complete! 🎉' : 'Rest Day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            isCompleted
                ? 'Great job today! Recovery is just as important as training.'
                : 'Your body recovers and grows stronger during rest days.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GENERATE PLAN CTA (unchanged)
  // ─────────────────────────────────────────────────────────────

  Widget _buildGeneratePlanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.white, size: 36),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Start Your Fitness Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'Generate a personalized workout plan tailored to your goals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGeneratePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Generate Plan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Private sub-widgets
// ═════════════════════════════════════════════════════════════════

/// Green pill chip showing the workout category (e.g. "Cardio").
class _CategoryChip extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _CategoryChip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Green rounded-rect block with a circular progress ring and percentage.
class _ProgressBlock extends StatelessWidget {
  final double progress;
  final int percent;
  final ThemeData theme;

  const _ProgressBlock({
    required this.progress,
    required this.percent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      ),
      child: Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: progress,
              trackColor: AppColors.white.withValues(alpha: 0.3),
              progressColor: AppColors.white,
              strokeWidth: 5,
            ),
            child: Center(
              child: Text(
                '$percent%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark "Continue the workout" pill button.
class _ContinueButton extends StatelessWidget {
  final VoidCallback? onTap;
  final ThemeData theme;
  final bool isDark;

  const _ContinueButton({
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.grey800 : AppColors.grey900;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
            vertical: AppDimensions.spacing12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Continue the workout',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: bgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a circular progress ring.
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
