import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/network/api_client.dart';

/// Screen to browse fitness goals and set the primary goal.
class FitnessGoalsScreen extends ConsumerStatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  ConsumerState<FitnessGoalsScreen> createState() =>
      _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends ConsumerState<FitnessGoalsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _goals = [];
  int? _currentPrimaryGoalId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final apiClient = ref.read(apiClientProvider);

      // Fetch goals and current user profile in parallel
      final results = await Future.wait([
        apiClient.get(ApiConstants.goals),
        apiClient.get(ApiConstants.currentUser),
      ]);

      final goalsData = results[0].data as Map<String, dynamic>;
      final userData = results[1].data as Map<String, dynamic>;

      final goalsList = (goalsData['data'] as List?)
              ?.map((g) => g as Map<String, dynamic>)
              .toList() ??
          [];

      final primaryGoal = userData['data']?['primaryGoal'];
      final primaryGoalId = primaryGoal?['goalId'] as int?;

      setState(() {
        _goals = goalsList;
        _currentPrimaryGoalId = primaryGoalId;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setPrimaryGoal(int goalId) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiConstants.userPrimaryGoal,
        data: {'goalId': goalId},
      );
      setState(() {
        _currentPrimaryGoalId = goalId;
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primary goal updated!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update goal: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Goals'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : _buildGoalsList(theme),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppDimensions.spacing16),
            Text('Failed to load goals', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacing16),
            ElevatedButton(
              onPressed: _loadGoals,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: _goals.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacing8),
      itemBuilder: (context, index) {
        final goal = _goals[index];
        final goalId = goal['goalId'] as int;
        final isPrimary = goalId == _currentPrimaryGoalId;

        return _GoalCard(
          goal: goal,
          isPrimary: isPrimary,
          isSaving: _saving,
          onTap: isPrimary ? null : () => _setPrimaryGoal(goalId),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isPrimary;
  final bool isSaving;
  final VoidCallback? onTap;

  const _GoalCard({
    required this.goal,
    required this.isPrimary,
    required this.isSaving,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: isPrimary ? 2 : 1,
        ),
      ),
      color: isPrimary
          ? theme.colorScheme.primary.withOpacity(0.05)
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.primary.withOpacity(0.15)
                      : AppColors.grey100,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Icon(
                  _getGoalIcon(goal['goalName'] as String?),
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['goalName'] as String? ?? 'Unknown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? theme.colorScheme.primary : null,
                      ),
                    ),
                    if (goal['description'] != null) ...[
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        goal['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                  child: Text(
                    'PRIMARY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!isPrimary && !isSaving)
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(String? goalName) {
    switch (goalName?.toLowerCase()) {
      case 'lose weight':
      case 'weight loss':
        return Icons.monitor_weight_outlined;
      case 'build muscle':
      case 'muscle gain':
        return Icons.fitness_center;
      case 'stay fit':
      case 'general fitness':
        return Icons.directions_run;
      case 'gain strength':
      case 'strength':
        return Icons.sports_gymnastics;
      default:
        return Icons.flag;
    }
  }
}
