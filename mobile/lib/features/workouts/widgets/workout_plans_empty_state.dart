import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Premium empty state widget for the Workout Plans screen.
/// Shows when no plans exist or when no active plans are available.
/// Features gradient CTA and fade-in entrance animation.
class WorkoutPlansEmptyState extends StatefulWidget {
  final bool hasPlans;
  final VoidCallback onGeneratePlan;

  const WorkoutPlansEmptyState({
    super.key,
    this.hasPlans = false,
    required this.onGeneratePlan,
  });

  @override
  State<WorkoutPlansEmptyState> createState() => _WorkoutPlansEmptyStateState();
}

class _WorkoutPlansEmptyStateState extends State<WorkoutPlansEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with gradient background
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 44,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                Text(
                  widget.hasPlans
                      ? 'No Active Plans'
                      : 'Start Your Fitness Journey',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacing8),

                Text(
                  widget.hasPlans
                      ? 'Activate an existing plan or create a new one to get back on track'
                      : 'Create your first personalized workout plan and achieve your goals',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // CTA Button with gradient
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: widget.onGeneratePlan,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(
                        widget.hasPlans ? 'Create New Plan' : 'Get Started',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLarge),
                        ),
                      ),
                    ),
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
