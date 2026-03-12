import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recommendation_models.dart';
import '../viewmodels/workout_plan_viewmodel.dart';
import '../viewmodels/workout_plan_state.dart';
import '../widgets/session_exercise_item.dart';

/// Screen for displaying workout session details
class WorkoutSessionDetailScreen extends ConsumerWidget {
  final int planId;
  final int dayNumber;

  const WorkoutSessionDetailScreen({
    super.key,
    required this.planId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutPlanViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Day $dayNumber'),
        centerTitle: true,
      ),
      body: _buildBody(context, state, theme),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutPlanState state, ThemeData theme) {
    WorkoutSessionResponse? session;

    if (state is WorkoutPlanLoaded) {
      session = state.currentSession;
      // Also check inline sessions
      if (session == null && state.plan.sessions.isNotEmpty) {
        session = state.plan.sessions.firstWhere(
          (s) => s.dayNumber == dayNumber,
          orElse: () => state.plan.sessions.first,
        );
      }
    } else if (state is WorkoutPlanLoadingSession) {
      return const Center(child: CircularProgressIndicator());
    }

    if (session == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Session not loaded',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    if (session.isRestDay) {
      return _buildRestDayContent(context, session, theme);
    }

    return _buildSessionContent(context, session, theme);
  }

  Widget _buildRestDayContent(
    BuildContext context,
    WorkoutSessionResponse session,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rest Day',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take this time to recover and regenerate',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _RestDayTip(
                      icon: Icons.bedtime,
                      title: 'Sleep Well',
                      subtitle: 'Aim for 7-9 hours of quality sleep',
                    ),
                    const Divider(),
                    _RestDayTip(
                      icon: Icons.water_drop,
                      title: 'Stay Hydrated',
                      subtitle: 'Drink plenty of water throughout the day',
                    ),
                    const Divider(),
                    _RestDayTip(
                      icon: Icons.restaurant,
                      title: 'Eat Nutritiously',
                      subtitle: 'Focus on protein and whole foods',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionContent(
    BuildContext context,
    WorkoutSessionResponse session,
    ThemeData theme,
  ) {
    return CustomScrollView(
      slivers: [
        // Session info header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.sessionName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                if (session.focusArea != null)
                  Chip(
                    avatar: Icon(Icons.fitness_center, size: 16),
                    label: Text(session.focusArea!),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (session.estimatedDuration != null)
                      _SessionInfoChip(
                        icon: Icons.timer,
                        label: '${session.estimatedDuration} min',
                      ),
                    const SizedBox(width: 12),
                    _SessionInfoChip(
                      icon: Icons.list,
                      label: '${session.exercises.length} exercises',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Warm-up notes
        if (session.warmUpNotes != null && session.warmUpNotes!.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.whatshot, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Warm-up',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          session.warmUpNotes!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Exercises list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Exercises',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SessionExerciseItem(
                sessionExercise: session.exercises[index],
                index: index,
                onTap: () => _navigateToExercise(
                  context,
                  session.exercises[index].exercise?.exerciseId,
                ),
              ),
              childCount: session.exercises.length,
            ),
          ),
        ),

        // Cool-down notes
        if (session.coolDownNotes != null && session.coolDownNotes!.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ac_unit, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cool-down',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          session.coolDownNotes!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  void _navigateToExercise(BuildContext context, String? exerciseId) {
    if (exerciseId == null) return;
    Navigator.pushNamed(
      context,
      '/exercises/$exerciseId',
      arguments: exerciseId,
    );
  }
}

class _SessionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SessionInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _RestDayTip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
