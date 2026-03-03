import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/onboarding_step_status.dart';
import '../../../shared/enums/onboarding_step_type.dart';
import '../../onboarding/models/onboarding_response.dart';
import '../../onboarding/services/onboarding_service.dart';

/// Read-only screen displaying the user's onboarding answers.
class OnboardingReviewScreen extends ConsumerStatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  ConsumerState<OnboardingReviewScreen> createState() =>
      _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState
    extends ConsumerState<OnboardingReviewScreen> {
  bool _loading = true;
  String? _error;
  OnboardingFlowResponse? _flow;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
  }

  Future<void> _loadOnboardingData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final service = ref.read(onboardingServiceProvider);
      final flow = await service.getOnboardingFlow();
      setState(() {
        _flow = flow;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Setup Summary'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : _buildContent(theme),
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
            Text('Failed to load onboarding data',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacing8),
            Text(_error!, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppDimensions.spacing16),
            ElevatedButton(
              onPressed: _loadOnboardingData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final steps = _flow?.steps ?? [];
    final completedSteps =
        steps.where((s) => s.status == OnboardingStepStatus.completed).toList();

    if (completedSteps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.checklist,
                  size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: AppDimensions.spacing16),
              Text('No onboarding data found',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Complete onboarding to see your setup summary here.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: completedSteps.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacing8),
      itemBuilder: (context, index) {
        final step = completedSteps[index];
        return _OnboardingStepCard(step: step);
      },
    );
  }
}

class _OnboardingStepCard extends StatelessWidget {
  final OnboardingStepResponse step;

  const _OnboardingStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStepIcon(step.stepType),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    step.title ?? step.stepType?.name ?? 'Step',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              _formatResponse(step),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResponse(OnboardingStepResponse step) {
    // responseData is a JSON string — parse it
    if (step.responseData == null || step.responseData!.isEmpty) {
      return 'No response';
    }

    try {
      final data = jsonDecode(step.responseData!);

      if (data is Map<String, dynamic>) {
        // Handle selected options (single/multiple choice)
        if (data.containsKey('selectedOptions')) {
          final options = data['selectedOptions'];
          if (options is List) {
            return options.map((o) => o.toString()).join(', ');
          }
        }

        if (data.containsKey('value')) {
          return data['value'].toString();
        }

        if (data.containsKey('days')) {
          final days = data['days'];
          if (days is List) {
            return days.join(', ');
          }
        }

        // Fallback: show all values
        return data.values
            .where((v) => v != null)
            .map((v) => v.toString())
            .join(', ');
      }

      return data.toString();
    } catch (_) {
      return step.responseData!;
    }
  }

  IconData _getStepIcon(OnboardingStepType? stepType) {
    switch (stepType) {
      case OnboardingStepType.fitnessGoal:
        return Icons.flag;
      case OnboardingStepType.fitnessLevel:
        return Icons.fitness_center;
      case OnboardingStepType.bodyMetrics:
        return Icons.straighten;
      case OnboardingStepType.equipment:
        return Icons.inventory_2;
      case OnboardingStepType.healthLimitations:
        return Icons.health_and_safety;
      case OnboardingStepType.schedule:
        return Icons.calendar_today;
      case OnboardingStepType.notifications:
        return Icons.notifications;
      default:
        return Icons.checklist;
    }
  }
}
