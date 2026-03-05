import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/enums/onboarding_input_type.dart';
import '../../../shared/enums/onboarding_step_status.dart';
import '../../../shared/enums/onboarding_step_type.dart';
import '../../onboarding/models/onboarding_request.dart';
import '../../onboarding/models/onboarding_response.dart';
import '../../onboarding/services/onboarding_service.dart';

/// Screen displaying all onboarding questions with answers.
/// Choice-based steps can be expanded inline to change the answer.
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

    if (steps.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return _ReviewStepTile(
          step: step,
          onAnswerChanged: (newResponseData) =>
              _handleAnswerChanged(step, newResponseData),
        );
      },
    );
  }

  Future<void> _handleAnswerChanged(
    OnboardingStepResponse step,
    String newResponseData,
  ) async {
    final stepId = step.stepId;
    if (stepId == null) return;

    try {
      final service = ref.read(onboardingServiceProvider);
      await service.submitStepResponse(
        stepId,
        SubmitOnboardingStepRequest(responseData: newResponseData),
      );
      // Reload the entire flow to get fresh data
      await _loadOnboardingData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Individual review row: icon · question · answer · chevron
// Expandable for choice-type steps.
// ---------------------------------------------------------------------------
class _ReviewStepTile extends StatefulWidget {
  final OnboardingStepResponse step;
  final ValueChanged<String> onAnswerChanged;

  const _ReviewStepTile({
    required this.step,
    required this.onAnswerChanged,
  });

  @override
  State<_ReviewStepTile> createState() => _ReviewStepTileState();
}

class _ReviewStepTileState extends State<_ReviewStepTile> {
  bool _expanded = false;
  // Tracks temp selection while editing multi-choice
  late Set<String> _tempSelectedKeys;

  bool get _isChoiceStep =>
      widget.step.inputType == OnboardingInputType.singleChoice ||
      widget.step.inputType == OnboardingInputType.multipleChoice;

  bool get _hasOptions => widget.step.options.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tempSelectedKeys = _getCurrentSelectedKeys();
  }

  @override
  void didUpdateWidget(covariant _ReviewStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _tempSelectedKeys = _getCurrentSelectedKeys();
    }
  }

  /// Extract currently selected option keys from responseData.
  Set<String> _getCurrentSelectedKeys() {
    final rd = widget.step.responseData;
    if (rd == null || rd.isEmpty) return {};

    try {
      final data = jsonDecode(rd);
      if (data is Map<String, dynamic>) {
        // "selectedOptions": [...]  (multiple choice / fitness goal etc.)
        if (data.containsKey('selectedOptions')) {
          final opts = data['selectedOptions'];
          if (opts is List) return opts.map((e) => e.toString()).toSet();
        }
        // "selectedOption": "..."  (single choice — some steps use this)
        if (data.containsKey('selectedOption')) {
          return {data['selectedOption'].toString()};
        }
        // "value": "..."
        if (data.containsKey('value')) {
          return {data['value'].toString()};
        }
      }
    } catch (_) {}
    return {};
  }

  /// Build the display text for the current answer.
  String _getAnswerDisplayText() {
    final step = widget.step;

    if (step.status != OnboardingStepStatus.completed) return '--';

    final rd = step.responseData;
    if (rd == null || rd.isEmpty) return '--';

    try {
      final data = jsonDecode(rd);
      if (data is Map<String, dynamic>) {
        // Choice steps — resolve keys/IDs to labels
        if (data.containsKey('selectedOptions')) {
          final opts = data['selectedOptions'];
          if (opts is List) {
            return _resolveLabels(opts.map((e) => e.toString()).toList());
          }
        }
        if (data.containsKey('selectedOption')) {
          return _resolveLabels([data['selectedOption'].toString()]);
        }
        if (data.containsKey('value')) {
          return data['value'].toString();
        }
        if (data.containsKey('days')) {
          final days = data['days'];
          if (days is List) return days.join(', ');
        }
        // Fallback: join all non-null values
        return data.values
            .where((v) => v != null)
            .map((v) => v.toString())
            .join(', ');
      }
      return data.toString();
    } catch (_) {
      return rd;
    }
  }

  /// Try to resolve option keys/IDs to their human-readable labels.
  String _resolveLabels(List<String> keys) {
    if (widget.step.options.isEmpty) return keys.join(', ');

    final labels = <String>[];
    for (final key in keys) {
      final match = widget.step.options.where((o) =>
          o.optionKey == key ||
          o.optionId?.toString() == key ||
          o.label == key);
      labels.add(match.isNotEmpty ? (match.first.label ?? key) : key);
    }
    return labels.join(', ');
  }

  void _toggleExpanded() {
    if (!_isChoiceStep || !_hasOptions) return;
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _tempSelectedKeys = _getCurrentSelectedKeys();
      }
    });
  }

  void _onSingleChoiceTap(OnboardingOptionResponse option) {
    final key = option.optionId?.toString() ?? option.optionKey ?? '';
    // Build responseData matching the onboarding format
    String responseData;
    if (widget.step.inputType == OnboardingInputType.singleChoice) {
      // Some steps use "selectedOption", some use "selectedOptions"
      // Check original format
      final rd = widget.step.responseData;
      bool usePlural = false;
      if (rd != null && rd.isNotEmpty) {
        try {
          final d = jsonDecode(rd);
          if (d is Map && d.containsKey('selectedOptions')) usePlural = true;
        } catch (_) {}
      }
      if (usePlural) {
        responseData = jsonEncode({'selectedOptions': [key]});
      } else {
        responseData = jsonEncode({'selectedOption': key});
      }
    } else {
      responseData = jsonEncode({'selectedOption': key});
    }
    setState(() => _expanded = false);
    widget.onAnswerChanged(responseData);
  }

  void _onMultiChoiceConfirm() {
    final responseData = jsonEncode({
      'selectedOptions': _tempSelectedKeys.toList(),
    });
    setState(() => _expanded = false);
    widget.onAnswerChanged(responseData);
  }

  void _toggleMultiOption(OnboardingOptionResponse option) {
    final key = option.optionId?.toString() ?? option.optionKey ?? '';
    setState(() {
      if (_tempSelectedKeys.contains(key)) {
        _tempSelectedKeys.remove(key);
      } else {
        _tempSelectedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answerText = _getAnswerDisplayText();
    final isAnswered = answerText != '--';

    return Column(
      children: [
        // ---- Main row ----
        InkWell(
          onTap: _isChoiceStep && _hasOptions ? _toggleExpanded : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing16,
              horizontal: AppDimensions.spacing4,
            ),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Icon(
                    _getStepIcon(widget.step.stepType),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                // Question text
                Expanded(
                  child: Text(
                    widget.step.title ?? widget.step.stepType?.name ?? 'Step',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing8),
                // Answer value
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    answerText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isAnswered
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing4),
                // Chevron
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: _isChoiceStep && _hasOptions
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        // Divider
        if (!_expanded)
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),

        // ---- Expanded options ----
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildOptionsPanel(theme),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildOptionsPanel(ThemeData theme) {
    if (widget.step.inputType == OnboardingInputType.singleChoice) {
      return _buildSingleChoiceOptions(theme);
    } else {
      return _buildMultiChoiceOptions(theme);
    }
  }

  Widget _buildSingleChoiceOptions(ThemeData theme) {
    final selectedKeys = _getCurrentSelectedKeys();

    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.spacing48,
        bottom: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.step.options.map((option) {
          final key =
              option.optionId?.toString() ?? option.optionKey ?? '';
          final isSelected = selectedKeys.contains(key);

          return InkWell(
            onTap: () => _onSingleChoiceTap(option),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing12,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text(
                      option.label ?? option.optionKey ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiChoiceOptions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.spacing48,
        bottom: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.step.options.map((option) {
            final key =
                option.optionId?.toString() ?? option.optionKey ?? '';
            final isSelected = _tempSelectedKeys.contains(key);

            return InkWell(
              onTap: () => _toggleMultiOption(option),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusLarge),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing12,
                  vertical: AppDimensions.spacing12,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Text(
                        option.label ?? option.optionKey ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Save button for multi-choice
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed:
                    _tempSelectedKeys.isNotEmpty ? _onMultiChoiceConfirm : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing8),
                ),
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
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
