import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/home_dashboard_models.dart';

/// Hero card showing today's scheduled workout session
class TodaysWorkoutCard extends StatelessWidget {
  final TodaySessionInfo? session;
  final bool hasPlans;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onGeneratePlan;

  const TodaysWorkoutCard({
    super.key,
    this.session,
    this.hasPlans = false,
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

  Widget _buildActiveSessionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Workout",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    session!.planName ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Session name
          Text(
            session!.sessionName ?? 'Workout Session',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.spacing8),

          // Exercise count and time
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.fitness_center_rounded,
                '${session!.exerciseCount ?? 0} exercises',
              ),
              const SizedBox(width: AppDimensions.spacing12),
              _buildInfoChip(
                context,
                Icons.timer_outlined,
                '~${session!.estimatedMinutes ?? 0} min',
              ),
            ],
          ),

          // Target muscles
          if (session!.targetMuscleGroups.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Wrap(
              spacing: 6,
              children: session!.targetMuscleGroups.map((muscle) {
                return Text(
                  muscle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: AppDimensions.spacing16),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Start Workout',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            isCompleted ? Icons.check_circle_outline_rounded : Icons.self_improvement_rounded,
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

  Widget _buildGeneratePlanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 36),
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
                  color: AppColors.white.withOpacity(0.85),
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
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.85), size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
