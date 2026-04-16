import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/onboarding_response.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../../onboarding_option_card.dart';

/// Generic SINGLE_CHOICE step - one option selected from step.options.
/// Calls the ViewModel directly via Riverpod on user interaction.
class SingleChoiceStep extends ConsumerStatefulWidget {
  final OnboardingStepResponse step;
  final String? existingData;

  const SingleChoiceStep({
    super.key,
    required this.step,
    this.existingData,
  });

  @override
  ConsumerState<SingleChoiceStep> createState() => _SingleChoiceStepState();
}

class _SingleChoiceStepState extends ConsumerState<SingleChoiceStep> {
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = widget.existingData ?? widget.step.responseData;
    if (data == null || data.isEmpty) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>?;
      if (map == null) return;
      final selected = map['optionId'] ?? map['selectedOption'];
      if (selected != null) {
        if (selected is int) {
          _selectedOptionId = selected;
        } else {
          final match = widget.step.options.where(
            (o) => o.optionKey == selected.toString(),
          );
          if (match.isNotEmpty) _selectedOptionId = match.first.optionId;
        }
      }
      if (_selectedOptionId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(onboardingViewModelProvider.notifier)
              .updateStepData({'optionId': _selectedOptionId});
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.step.options;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            widget.step.title ?? 'Select one',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.step.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.step.subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: _selectedOptionId == option.optionId,
                onTap: () {
                  setState(() => _selectedOptionId = option.optionId);
                  ref.read(onboardingViewModelProvider.notifier)
                      .updateStepData({'optionId': option.optionId});
                },
              ),
            );
          }),
          if (widget.step.helpText != null) ...[
            const SizedBox(height: 16),
            _buildHelpText(theme, widget.step.helpText!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHelpText(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
