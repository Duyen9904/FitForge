import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';

/// Hero section widget for workout plan detail screen.
/// Displays the hero image, plan title, session info, and badges.
class PlanHeroSection extends StatelessWidget {
  final WorkoutPlanResponse plan;
  final WorkoutSessionResponse? loadedSession;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const PlanHeroSection({
    super.key,
    required this.plan,
    this.loadedSession,
    required this.onBack,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    // Use loaded session info for title; fallback to first session stub
    final session = loadedSession;
    final sessionTitle = session != null
        ? 'Day ${session.dayNumber.toString().padLeft(2, '0')} - ${session.sessionName}'
        : plan.planName;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing6),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: AppDimensions.iconSmall, color: AppColors.white),
        ),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onPressed: onMenu,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(session),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundLight.withValues(alpha: 0.0),
                    AppColors.backgroundLight.withValues(alpha: 0.3),
                    AppColors.backgroundLight.withValues(alpha: 0.85),
                    AppColors.backgroundLight,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppDimensions.spacing20,
              right: AppDimensions.spacing20,
              bottom: AppDimensions.spacing16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  if (session?.focusArea != null) ...[
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      session!.focusArea!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildBadgesRow(context, session),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context, WorkoutSessionResponse? session) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing8,
            vertical: AppDimensions.spacing4,
          ),
          decoration: BoxDecoration(
            color: plan.isActive ? AppColors.success : AppColors.grey400,
            borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                plan.isActive ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: AppColors.white,
              ),
              const SizedBox(width: AppDimensions.spacing4),
              Text(
                plan.isActive ? 'Active' : 'Inactive',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        if (session?.estimatedDuration != null)
          _buildInfoBadge(
            context,
            icon: Icons.timer_outlined,
            label: '${session!.estimatedDuration} Min',
          ),
        if (session?.exercises.isNotEmpty ?? false) ...[
          const SizedBox(width: AppDimensions.spacing12),
          _buildInfoBadge(
            context,
            icon: Icons.local_fire_department_outlined,
            label: '${_estimateCalories(session!)} Cal',
          ),
        ],
        if (plan.difficultyLevel != null) ...[
          const SizedBox(width: AppDimensions.spacing12),
          _buildInfoBadge(
            context,
            icon: Icons.signal_cellular_alt,
            label: _formatText(plan.difficultyLevel!),
          ),
        ],
      ],
    );
  }

  Widget _buildHeroImage(WorkoutSessionResponse? session) {
    final imageUrl = session?.exercises
        .where((e) => e.exercise?.imageUrl != null)
        .map((e) => e.exercise!.imageUrl!)
        .firstOrNull;

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.grey200),
        errorWidget: (_, __, ___) => _buildDefaultHero(),
      );
    }

    return _buildDefaultHero();
  }

  Widget _buildDefaultHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.grey300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: AppDimensions.iconXLarge * 1.67,
          color: AppColors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context,
      {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing6,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSmall, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  int _estimateCalories(WorkoutSessionResponse session) {
    int totalCal = 0;
    for (final exercise in session.exercises) {
      final calPerMin = exercise.exercise?.caloriesBurnedPerMin ?? 5;
      final sets = exercise.sets ?? 3;
      final reps = exercise.repetitions ?? 10;
      final minutesPerExercise = (sets * reps * 2) / 60;
      totalCal += (calPerMin * minutesPerExercise).round();
    }
    return totalCal > 0 ? totalCal : 230;
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
