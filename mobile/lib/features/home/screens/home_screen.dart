import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../recommendation/viewmodels/workout_plan_viewmodel.dart';
import '../../workouts/viewmodels/workout_plans_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/home_state.dart';
import '../models/home_dashboard_models.dart';
import '../models/plan_generation_option.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/today_activities_hero_card.dart';
import '../widgets/home_weekly_calendar.dart';
import '../widgets/today_exercises_timeline.dart';
import '../widgets/plan_generation_options_sheet.dart';

/// Redesigned Home Screen matching system resource colors and UX requests:
/// - Resource system colors (AppColors.primary, secondary, etc.)
/// - AI-generated icon in top-right app bar for plan generation
/// - Top-left profile avatar
/// - Dark hero card for "Today's Activities" with target muscle focus (Back, Full Body, etc.)
/// - Expandable calendar that reveals the 7-day strip when clicking the calendar icon
/// - Vertical timeline for daily exercises with muscle group metadata
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadDashboard();
      ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
    });
  }

  /// Formats the target focus muscle group for display
  String _getTargetMuscleFocus(TodaySessionInfo? session) {
    if (session?.targetMuscleGroups.isNotEmpty ?? false) {
      return session!.targetMuscleGroups
          .map((m) => m[0].toUpperCase() + m.substring(1).toLowerCase())
          .join(' & ');
    }
    if (session?.sessionName != null && session!.sessionName!.isNotEmpty) {
      return session!.sessionName!;
    }
    return 'Back & Full Body';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final homeState = ref.watch(homeViewModelProvider);

    final userName = authState.maybeWhen(
      authenticated: (user) => user.username,
      orElse: () => 'User',
    );

    final dashboard = homeState.maybeWhen(
      loaded: (_, __, d) => d,
      orElse: () => null,
    );

    final focusMuscle = _getTargetMuscleFocus(dashboard?.todaySession);

    // Compute scheduled workout dates for the calendar indicators
    final scheduledDates = _getScheduledDates(dashboard);

    // Build timeline items for the selected date
    final timelineItems = _buildTimelineItems(dashboard, _selectedDate, focusMuscle);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(homeViewModelProvider.notifier).refresh();
            ref.read(workoutPlansViewModelProvider.notifier).loadPlans();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar: Left Avatar, Right Search, AI Plan Generator, Notifications
                HomeTopBar(
                  userName: userName,
                  onAvatarTap: () => context.go(Routes.profile),
                  onSearchTap: () => context.push(Routes.exercises),
                  onGeneratePlan: _showPlanGenerationOptionsSheet,
                  onNotificationsTap: () => context.push(Routes.notifications),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // 2. Today's Activities Hero Card with Focus Muscle (Back, Body, etc.)
                TodayActivitiesHeroCard(
                  session: dashboard?.todaySession,
                  weeklyStats: dashboard?.weeklyStats,
                  focusMuscleGroup: focusMuscle,
                  onTap: () {
                    final session = dashboard?.todaySession;
                    if (session != null && session.planId != null) {
                      context.push(Routes.workoutPlanDetail(session.planId!));
                    } else {
                      _showPlanGenerationOptionsSheet();
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // 3. Expandable Weekly Calendar (Click calendar icon to expand/collapse)
                HomeWeeklyCalendar(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  workoutDates: scheduledDates,
                  initialExpanded: false,
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // 4. Daily Exercises Timeline Section
                TodayExercisesTimeline(
                  items: timelineItems,
                  focusMuscleGroup: focusMuscle,
                  onGeneratePlan: _showPlanGenerationOptionsSheet,
                  onFilterTap: () => context.push(Routes.workouts),
                ),

                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Collects active workout dates to show indicators in the weekly calendar
  Set<String> _getScheduledDates(HomeDashboardResponse? dashboard) {
    final dates = <String>{};
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    if (dashboard?.todaySession != null) {
      final scheduledDate = dashboard!.todaySession!.scheduledDate ?? todayStr;
      dates.add(scheduledDate);
    }

    if (dashboard?.activePlans.isNotEmpty ?? false) {
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: now.weekday - 1 - i));
        if (day.weekday == DateTime.monday ||
            day.weekday == DateTime.wednesday ||
            day.weekday == DateTime.friday) {
          dates.add(DateFormat('yyyy-MM-dd').format(day));
        }
      }
    } else {
      dates.add(todayStr);
    }

    return dates;
  }

  /// Builds exercise timeline items for the selected date
  List<TimelineExerciseItem> _buildTimelineItems(
    HomeDashboardResponse? dashboard,
    DateTime selectedDate,
    String focusMuscle,
  ) {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(selectedDate, now);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final hasScheduledWorkout = _getScheduledDates(dashboard).contains(dateStr);

    if (isToday || hasScheduledWorkout) {
      final session = dashboard?.todaySession;
      final planId = session?.planId;

      return [
        TimelineExerciseItem(
          startTime: '11:35',
          endTime: '13:05',
          title: 'Cardio',
          category: 'cardio',
          targetMuscle: 'Cardiovascular & Endurance',
          currentStep: 4,
          totalSteps: 6,
          calories: '1200 kcal',
          heartRate: '90 bpm',
          duration: '03:00 hr',
          onTap: () {
            if (planId != null) {
              context.push(Routes.workoutPlanDetail(planId));
            } else {
              context.push(Routes.exercises);
            }
          },
        ),
        TimelineExerciseItem(
          startTime: '11:35',
          endTime: '14:45',
          title: session?.sessionName ?? 'Muscle',
          category: 'muscle',
          targetMuscle: focusMuscle,
          currentStep: 5,
          totalSteps: 6,
          calories: '1200 kcal',
          heartRate: '90 bpm',
          duration: '03:00 hr',
          onTap: () {
            if (planId != null) {
              context.push(Routes.workoutPlanDetail(planId));
            } else {
              context.push(Routes.exercises);
            }
          },
        ),
        TimelineExerciseItem(
          startTime: '14:50',
          endTime: '15:15',
          title: 'Weight',
          category: 'weight',
          targetMuscle: 'Back & Core Strength',
          currentStep: 6,
          totalSteps: 6,
          calories: '1200 kcal',
          heartRate: '90 bpm',
          duration: '03:00 hr',
          onTap: () {
            if (planId != null) {
              context.push(Routes.workoutPlanDetail(planId));
            } else {
              context.push(Routes.exercises);
            }
          },
        ),
      ];
    }

    return [];
  }

  /// Show plan generation options bottom sheet
  void _showPlanGenerationOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlanGenerationOptionsSheet(
        onOptionSelected: (option) {
          if (option == PlanGenerationOption.fromOnboarding) {
            _showOnboardingConfirmation();
          } else if (option == PlanGenerationOption.customAI) {
            context.push(Routes.generateAIPlan);
          } else {
            _showComingSoonSnackbar(option);
          }
        },
      ),
    );
  }

  /// Show confirmation dialog for onboarding-based generation
  void _showOnboardingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Plan from Profile?'),
        content: const Text(
          'We\'ll use your onboarding answers to create a personalized workout plan.\n\nDo you want to revise any of your answers first?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(Routes.onboarding);
            },
            child: const Text('Revise Answers'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _generateWorkoutPlan();
            },
            child: const Text('Generate Now'),
          ),
        ],
      ),
    );
  }

  /// Show coming soon snackbar for unavailable options
  void _showComingSoonSnackbar(PlanGenerationOption option) {
    final optionName = option == PlanGenerationOption.createOwn
        ? 'Manual plan creation'
        : 'Custom AI generation';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$optionName is coming soon!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Generate workout plan from onboarding data
  void _generateWorkoutPlan() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select start date for your plan',
    );
    if (picked == null || !mounted) return;
    final startDate =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

    ref.read(workoutPlanViewModelProvider.notifier).generatePlan(startDate);
    context.push(Routes.workoutRecommendation);
  }
}
