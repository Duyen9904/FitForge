import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/workout_plan_viewmodel.dart';
import '../viewmodels/workout_plan_state.dart';
import '../widgets/workout_plan_card.dart';
import '../widgets/workout_session_card.dart';

/// Screen for displaying and managing workout recommendations
class WorkoutRecommendationScreen extends ConsumerStatefulWidget {
  const WorkoutRecommendationScreen({super.key});

  @override
  ConsumerState<WorkoutRecommendationScreen> createState() =>
      _WorkoutRecommendationScreenState();
}

class _WorkoutRecommendationScreenState
    extends ConsumerState<WorkoutRecommendationScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutPlanViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        centerTitle: true,
        actions: [
          if (state is WorkoutPlanLoaded)
            IconButton(
              onPressed: () => _showPlanInfo(context, state),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Plan Info',
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(WorkoutPlanState state, ThemeData theme) {
    return state.when(
      initial: () => _buildInitialState(theme),
      loading: () => const Center(child: CircularProgressIndicator()),
      generating: () => _buildGeneratingState(theme),
      adjusting: (currentPlan) => _buildAdjustingState(theme, currentPlan),
      loadingSession: (plan, dayNumber) =>
          _buildLoadedState(plan, isLoadingSession: true, loadingDay: dayNumber),
      loaded: (plan, currentSession, currentDay) =>
          _buildLoadedState(plan, session: currentSession, currentDay: currentDay),
      error: (message) => _buildErrorState(message, theme),
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workout Plan Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a personalized workout plan based on your profile and goals',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Plan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Generating your workout plan...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your profile and goals',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustingState(ThemeData theme, dynamic currentPlan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Adjusting your workout plan...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your recent workout behavior',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    dynamic plan, {
    dynamic session,
    int currentDay = 1,
    bool isLoadingSession = false,
    int? loadingDay,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(workoutPlanViewModelProvider.notifier).reset();
      },
      child: CustomScrollView(
        slivers: [
          // Plan card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WorkoutPlanCard(
                plan: plan,
                onAdjustPressed: () => _adjustPlan(plan.planId),
              ),
            ),
          ),

          // Sessions header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Weekly Sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Sessions list
          if (plan.sessions.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sessionItem = plan.sessions[index];
                    final isLoading = isLoadingSession && loadingDay == sessionItem.dayNumber;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Stack(
                        children: [
                          WorkoutSessionCard(
                            session: sessionItem,
                            isSelected: currentDay == sessionItem.dayNumber,
                            onTap: () => _navigateToSession(
                              plan.planId,
                              sessionItem.dayNumber,
                            ),
                          ),
                          if (isLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: plan.sessions.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Sessions will be loaded on-demand',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePlan() async {
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
  }

  void _adjustPlan(int planId) {
    ref.read(workoutPlanViewModelProvider.notifier).adjustPlan(planId);
  }

  void _navigateToSession(int planId, int dayNumber) {
    ref.read(workoutPlanViewModelProvider.notifier)
        .loadSessionForDay(planId, dayNumber);
    Navigator.pushNamed(
      context,
      '/recommendation/workout/session',
      arguments: {'planId': planId, 'dayNumber': dayNumber},
    );
  }

  void _showPlanInfo(BuildContext context, WorkoutPlanLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.plan.algorithmVersion != null)
              _InfoRow('Algorithm', state.plan.algorithmVersion!),
            if (state.plan.version != null)
              _InfoRow('Version', 'v${state.plan.version}'),
            if (state.plan.recommendationReason != null)
              _InfoRow('Reason', state.plan.recommendationReason!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
