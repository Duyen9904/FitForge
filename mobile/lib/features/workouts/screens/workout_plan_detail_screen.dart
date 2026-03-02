import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/workout_plan_models.dart';
import '../viewmodels/workout_plan_detail_state.dart';
import '../viewmodels/workout_plan_detail_viewmodel.dart';
import '../widgets/plan_hero_section.dart';
import '../widgets/session_day_selector.dart';
import '../widgets/session_exercise_list.dart';
import '../widgets/edit_session_exercise_sheet.dart';
import '../widgets/edit_plan_metadata_sheet.dart';
import '../widgets/edit_session_metadata_sheet.dart';
import '../widgets/start_workout_button.dart';
import '../widgets/reschedule_workout_button.dart';

/// Workout Plan Detail Screen
/// Shows plan info, session selector, exercise list, and start button.
class WorkoutPlanDetailScreen extends ConsumerStatefulWidget {
  final int planId;

  const WorkoutPlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<WorkoutPlanDetailScreen> createState() =>
      _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState
    extends ConsumerState<WorkoutPlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(workoutPlanDetailViewModelProvider.notifier)
          .loadPlan(widget.planId);
    });
  }

  Future<void> _showPlanMenu(BuildContext context, WorkoutPlanResponse plan) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.spacing8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.grey700),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(Icons.copy, color: AppColors.grey700),
              title: const Text('Duplicate'),
              onTap: () => Navigator.pop(context, 'duplicate'),
            ),
            ListTile(
              leading: Icon(
                plan.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: AppColors.grey700,
              ),
              title: Text(plan.isActive ? 'Deactivate' : 'Activate'),
              onTap: () => Navigator.pop(context, 'toggle_active'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: AppDimensions.spacing8),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      switch (result) {
        case 'edit':
          _showEditPlanMetadataSheet(context, plan);
          break;
        case 'duplicate':
          await _handleDuplicate(context, plan);
          break;
        case 'toggle_active':
          await _handleToggleActive(context);
          break;
        case 'delete':
          await _handleDelete(context);
          break;
      }
    }
  }

  Future<void> _handleDuplicate(BuildContext context, WorkoutPlanResponse plan) async {
    final controller = TextEditingController(text: '${plan.planName} Copy');
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Workout Plan'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Plan Name',
              hintText: 'Enter a name for the duplicated plan',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a plan name';
              }
              return null;
            },
            maxLength: 100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      try {
        await ref.read(workoutPlanDetailViewModelProvider.notifier).duplicatePlan(newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Workout plan duplicated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to duplicate plan: ${e.toString()}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleToggleActive(BuildContext context) async {
    try {
      await ref.read(workoutPlanDetailViewModelProvider.notifier).toggleActive();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Active status updated'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Plan'),
        content: const Text(
          'Are you sure you want to delete this workout plan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(workoutPlanDetailViewModelProvider.notifier).deletePlan();
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Workout plan deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete plan: ${e.toString()}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showEditPlanMetadataSheet(
      BuildContext context, WorkoutPlanResponse plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (_) => EditPlanMetadataSheet(
        plan: plan,
        onSave: (request) async {
          try {
            await ref
                .read(workoutPlanDetailViewModelProvider.notifier)
                .updatePlanMetadata(request);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Plan updated'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update: ${e.toString()}'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditSessionSheet(
      BuildContext context, WorkoutSessionResponse session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (_) => EditSessionMetadataSheet(
        session: session,
        onSave: (request) async {
          try {
            await ref
                .read(workoutPlanDetailViewModelProvider.notifier)
                .updateSessionMetadata(session.sessionId, request);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Session updated'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update: ${e.toString()}'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutPlanDetailViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        loaded: (plan, selectedSessionIndex, sessionLoadingState,
                loadedSession, sessionError, currentWeekNumber, totalWeeks,
                weekSessions, weekLabel) =>
            _buildContent(context, plan, selectedSessionIndex,
                sessionLoadingState, loadedSession, sessionError,
                currentWeekNumber, totalWeeks, weekSessions, weekLabel),
        error: (message) => SafeArea(
          child: Column(
            children: [
              _buildBackButton(context),
              Expanded(
                child: ErrorState(
                  message: message,
                  onRetry: () => ref
                      .read(workoutPlanDetailViewModelProvider.notifier)
                      .loadPlan(widget.planId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WorkoutPlanResponse plan,
    int selectedSessionIndex,
    SessionLoadingState sessionLoadingState,
    WorkoutSessionResponse? loadedSession,
    String? sessionError,
    int currentWeekNumber,
    int totalWeeks,
    List<WorkoutSessionResponse> weekSessions,
    String weekLabel,
  ) {
    final showSelector = totalWeeks > 0;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Hero section
              PlanHeroSection(
                plan: plan,
                loadedSession: loadedSession,
                onBack: () => context.pop(),
                onMenu: () => _showPlanMenu(context, plan),
              ),

              // Session day selector with week navigation
              if (showSelector)
                SliverToBoxAdapter(
                  child: SessionDaySelector(
                    weekSessions: weekSessions,
                    weekLabel: weekLabel.isNotEmpty ? weekLabel : 'Week $currentWeekNumber',
                    currentWeekNumber: currentWeekNumber,
                    totalWeeks: totalWeeks,
                    selectedIndex: selectedSessionIndex,
                    onDaySelected: (index) {
                      ref
                          .read(workoutPlanDetailViewModelProvider.notifier)
                          .selectSession(index);
                    },
                    onPrevWeek: () {
                      ref
                          .read(workoutPlanDetailViewModelProvider.notifier)
                          .goToPrevWeek();
                    },
                    onNextWeek: () {
                      ref
                          .read(workoutPlanDetailViewModelProvider.notifier)
                          .goToNextWeek();
                    },
                  ),
                ),

              // Session edit button
              if (loadedSession != null && !loadedSession.isRestDay)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loadedSession.sessionName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.grey600),
                          tooltip: 'Edit Session',
                          onPressed: () => _showEditSessionSheet(context, loadedSession),
                        ),
                      ],
                    ),
                  ),
                ),

              // Description
              if (plan.description != null && plan.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing8,
                    ),
                    child: Text(
                      plan.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                    ),
                  ),
                ),

              // Exercise list (lazy-loaded)
              SliverToBoxAdapter(
                child: SessionExerciseList(
                  loadingState: sessionLoadingState,
                  session: loadedSession,
                  errorMessage: sessionError,
                  onRetry: () {
                    final currentState = ref.read(workoutPlanDetailViewModelProvider);
                    if (currentState is WorkoutPlanDetailLoaded) {
                      ref
                          .read(workoutPlanDetailViewModelProvider.notifier)
                          .loadSessionsForWeek(
                              currentState.plan.planId,
                              currentState.currentWeekNumber);
                    }
                  },
                  onDeleteExercise: (exercise) async {
                    try {
                      await ref
                          .read(workoutPlanDetailViewModelProvider.notifier)
                          .deleteSessionExercise(exercise.sessionExerciseId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Exercise removed'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  onEditExercise: (exercise) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.radiusXLarge)),
                      ),
                      builder: (_) => EditSessionExerciseSheet(
                        sessionExercise: exercise,
                        onSave: (request) async {
                          try {
                            await ref
                                .read(workoutPlanDetailViewModelProvider.notifier)
                                .updateSessionExercise(
                                    exercise.sessionExerciseId, request);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Exercise updated'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // Reschedule button
              SliverToBoxAdapter(
                child: RescheduleWorkoutButton(
                  loadedSession: loadedSession,
                  onReschedule: (newDate) => ref
                      .read(workoutPlanDetailViewModelProvider.notifier)
                      .rescheduleSession(newDate),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.spacing24),
              ),
            ],
          ),
        ),

        // Start Workout button
        StartWorkoutButton(loadedSession: loadedSession),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing6),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new,
            size: AppDimensions.iconSmall, color: AppColors.white),
      ),
      onPressed: () => context.pop(),
    );
  }
}
