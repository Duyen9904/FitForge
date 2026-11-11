import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/workout_plan_models.dart';
import 'workout_plan_card.dart';
import '../../../ui/core/states/empty_screen.dart';

/// Workout plans list widget with shimmer loading, pagination, and
/// entrance animations. Handles loaded, empty-filter, and loading states.
class WorkoutPlansList extends StatefulWidget {
  final List<WorkoutPlanSummaryResponse> plans;
  final bool hasMore;
  final String? selectedDifficulty;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final VoidCallback onToggleActive;
  final Future<void> Function(int planId) onToggleActivePlan;
  final Future<void> Function(int planId, String newName) onDuplicatePlan;
  final Future<void> Function(int planId) onDeletePlan;

  const WorkoutPlansList({
    super.key,
    required this.plans,
    required this.hasMore,
    this.selectedDifficulty,
    required this.scrollController,
    required this.onRefresh,
    required this.onToggleActive,
    required this.onToggleActivePlan,
    required this.onDuplicatePlan,
    required this.onDeletePlan,
  });

  @override
  State<WorkoutPlansList> createState() => _WorkoutPlansListState();
}

class _WorkoutPlansListState extends State<WorkoutPlansList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Client-side filter by difficulty
    final filteredPlans = widget.selectedDifficulty == null
        ? widget.plans
        : widget.plans
            .where((p) =>
                p.difficultyLevel?.toUpperCase() ==
                widget.selectedDifficulty!.toUpperCase())
            .toList();

    if (filteredPlans.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyFilterState(theme),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= filteredPlans.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          }

          final plan = filteredPlans[index];
          return _AnimatedPlanCard(
            index: index,
            child: WorkoutPlanCard(
              plan: plan,
              onTap: () {
                context.push(Routes.workoutPlanDetail(plan.planId));
              },
              onToggleActive: () => widget.onToggleActivePlan(plan.planId),
              onDuplicate: (newName) =>
                  widget.onDuplicatePlan(plan.planId, newName),
              onDelete: () => widget.onDeletePlan(plan.planId),
            ),
          );
        },
        childCount: filteredPlans.length + (widget.hasMore ? 1 : 0),
      ),
    );
  }

  Widget _buildEmptyFilterState(ThemeData theme) {
    return EmptyScreen(
      illustrationHeight: 160,
      title: 'No plans found',
      description: widget.selectedDifficulty != null
          ? 'No ${widget.selectedDifficulty} plans available'
          : 'Try adjusting your filters',
    );
  }
}

/// Shimmer loading skeleton for the workout plans list.
/// Shows 3 placeholder cards during initial load.
class WorkoutPlansShimmer extends StatelessWidget {
  const WorkoutPlansShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _ShimmerCard(index: index),
        childCount: 3,
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final int index;
  const _ShimmerCard({required this.index});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.spacing6,
          ),
          child: Container(
            height: AppDimensions.spacing64 * 2.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * _controller.value, 0),
                end: Alignment(-1 + 2 * _controller.value + 1, 0),
                colors: [
                  AppColors.grey100,
                  AppColors.grey200,
                  AppColors.grey100,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animates each plan card entrance with a staggered fade + slide.
class _AnimatedPlanCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedPlanCard({required this.index, required this.child});

  @override
  State<_AnimatedPlanCard> createState() => _AnimatedPlanCardState();
}

class _AnimatedPlanCardState extends State<_AnimatedPlanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Stagger the animation based on index
    Future.delayed(
      Duration(milliseconds: 50 * widget.index.clamp(0, 8)),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
