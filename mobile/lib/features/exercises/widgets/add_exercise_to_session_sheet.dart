import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../workouts/models/workout_plan_models.dart';
import '../../workouts/repositories/workout_plan_repository.dart';

/// Bottom sheet that lets the user add an exercise to an existing
/// workout-plan session in two steps: pick plan → pick session.
class AddExerciseToSessionSheet extends ConsumerStatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const AddExerciseToSessionSheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  ConsumerState<AddExerciseToSessionSheet> createState() =>
      _AddExerciseToSessionSheetState();
}

class _AddExerciseToSessionSheetState
    extends ConsumerState<AddExerciseToSessionSheet> {
  // Step 0 = pick plan, Step 1 = pick session
  int _step = 0;

  bool _loadingPlans = true;
  bool _loadingSessions = false;
  bool _adding = false;
  String? _errorMessage;

  List<WorkoutPlanSummaryResponse> _plans = [];
  WorkoutPlanSummaryResponse? _selectedPlan;
  List<WorkoutSessionResponse> _sessions = [];
  int _currentWeek = 1;
  int _maxWeeks = 1;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // ───────────────────── data helpers ─────────────────────

  Future<void> _loadPlans() async {
    try {
      final repo = ref.read(workoutPlanRepositoryProvider);
      final page = await repo.getUserPlans(page: 0, size: 50);
      if (!mounted) return;
      setState(() {
        _plans = page.content;
        _loadingPlans = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load plans';
        _loadingPlans = false;
      });
    }
  }

  Future<void> _onPlanSelected(WorkoutPlanSummaryResponse plan) async {
    setState(() {
      _selectedPlan = plan;
      _loadingSessions = true;
      _step = 1;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(workoutPlanRepositoryProvider);

      // Fetch plan metadata to determine the current week
      final fullPlan = await repo.getPlanById(plan.planId);

      // Compute current week from startDate
      int currentWeek = 1;
      final maxWeeks = fullPlan.durationWeeks ?? 1;
      if (fullPlan.startDate != null) {
        final start = DateTime.tryParse(fullPlan.startDate!);
        if (start != null) {
          final now = DateTime.now();
          final diff = now.difference(start).inDays;
          if (diff >= 0) {
            currentWeek = (diff ~/ 7) + 1;
          }
          if (currentWeek > maxWeeks) currentWeek = maxWeeks;
          if (currentWeek < 1) currentWeek = 1;
        }
      }

      _currentWeek = currentWeek;
      _maxWeeks = maxWeeks;

      await _loadSessionsForWeek(plan.planId, currentWeek);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load sessions';
        _loadingSessions = false;
      });
    }
  }

  Future<void> _loadSessionsForWeek(int planId, int week) async {
    setState(() {
      _loadingSessions = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(workoutPlanRepositoryProvider);
      final sessions = await repo.getSessionsForWeek(planId, week);
      if (!mounted) return;
      setState(() {
        _currentWeek = week;
        _sessions = sessions.where((s) => !s.isRestDay).toList();
        _loadingSessions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load sessions';
        _loadingSessions = false;
      });
    }
  }

  Future<void> _onSessionSelected(WorkoutSessionResponse session) async {
    setState(() => _adding = true);

    try {
      final repo = ref.read(workoutPlanRepositoryProvider);
      final request = CreateSessionExerciseRequest(
        exerciseId: widget.exerciseId,
        sets: 3,
        repetitions: 10,
        orderIndex: session.exerciseCount,
      );
      await repo.addExercises(
        _selectedPlan!.planId,
        session.sessionId,
        [request],
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.exerciseName} added to ${session.sessionName}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adding = false;
        _errorMessage = 'Failed to add exercise';
      });
    }
  }

  // ───────────────────── build ─────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildTitle(context),
            const SizedBox(height: AppDimensions.spacing4),
            _buildSubtitle(context),
            const SizedBox(height: AppDimensions.spacing16),
            if (_errorMessage != null) _buildError(context),
            if (_step == 0) _buildPlanList(context),
            if (_step == 1) ...[
              _buildWeekSelector(context),
              const SizedBox(height: AppDimensions.spacing12),
              _buildSessionList(context),
            ],
            const SizedBox(height: AppDimensions.spacing8),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        if (_step == 1)
          GestureDetector(
            onTap: () => setState(() {
              _step = 0;
              _sessions = [];
              _selectedPlan = null;
              _errorMessage = null;
            }),
            child: const Padding(
              padding: EdgeInsets.only(right: AppDimensions.spacing8),
              child: Icon(Icons.arrow_back_ios, size: 18),
            ),
          ),
        Expanded(
          child: Text(
            _step == 0 ? 'Add to Workout Plan' : _selectedPlan?.planName ?? '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _step == 0
            ? 'Select a plan to add "${widget.exerciseName}"'
            : 'Select a session',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Text(
          _errorMessage!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
        ),
      ),
    );
  }

  // ───────────────────── Week selector ─────────────────────

  Widget _buildWeekSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: _currentWeek > 1 ? AppColors.primary : AppColors.grey300,
            onPressed: _currentWeek > 1 && !_loadingSessions
                ? () => _loadSessionsForWeek(
                    _selectedPlan!.planId, _currentWeek - 1)
                : null,
          ),
          Text(
            'Week $_currentWeek of $_maxWeeks',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: _currentWeek < _maxWeeks
                ? AppColors.primary
                : AppColors.grey300,
            onPressed: _currentWeek < _maxWeeks && !_loadingSessions
                ? () => _loadSessionsForWeek(
                    _selectedPlan!.planId, _currentWeek + 1)
                : null,
          ),
        ],
      ),
    );
  }

  // ───────────────────── Step 0: plan list ─────────────────────

  Widget _buildPlanList(BuildContext context) {
    if (_loadingPlans) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacing24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 48, color: AppColors.grey300),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              'No workout plans yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _plans.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (context, index) {
          final plan = _plans[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing4,
              vertical: AppDimensions.spacing4,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
            ),
            title: Text(
              plan.planName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
            ),
            subtitle: Text(
              [
                if (plan.difficultyLevel != null) plan.difficultyLevel!,
                if (plan.sessionCount != null)
                  '${plan.sessionCount} sessions',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (plan.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing8,
                      vertical: AppDimensions.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusRound),
                    ),
                    child: Text(
                      'Active',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                const SizedBox(width: AppDimensions.spacing4),
                const Icon(Icons.chevron_right,
                    color: AppColors.grey400, size: 20),
              ],
            ),
            onTap: () => _onPlanSelected(plan),
          );
        },
      ),
    );
  }

  // ───────────────────── Step 1: session list ─────────────────────

  Widget _buildSessionList(BuildContext context) {
    if (_loadingSessions || _adding) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              if (_adding) ...[
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  'Adding exercise…',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Text(
          'No sessions found in this plan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _sessions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing4,
              vertical: AppDimensions.spacing4,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Center(
                child: Text(
                  'D${session.dayNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
            ),
            title: Text(
              session.sessionName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
            ),
            subtitle: Text(
              [
                if (session.scheduledDate != null)
                  _formatDate(session.scheduledDate!),
                if (session.focusArea != null) session.focusArea!,
                '${session.exerciseCount} exercises',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
            trailing: const Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 22),
            onTap: () => _onSessionSelected(session),
          );
        },
      ),
    );
  }

  // ───────────────────── helpers ─────────────────────

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
