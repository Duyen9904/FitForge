import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/onboarding_response.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../../onboarding_option_card.dart';

/// Generic MULTIPLE_CHOICE step - multiple options selected from step.options.
/// Calls the ViewModel directly via Riverpod on user interaction.
class MultipleChoiceStep extends ConsumerStatefulWidget {
  final OnboardingStepResponse step;
  final String? existingData;

  const MultipleChoiceStep({
    super.key,
    required this.step,
    this.existingData,
  });

  @override
  ConsumerState<MultipleChoiceStep> createState() => _MultipleChoiceStepState();
}

class _MultipleChoiceStepState extends ConsumerState<MultipleChoiceStep> {
  final Set<String> _selectedKeys = {};

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    // Multiple choice is always valid — report initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportData();
    });
  }

  void _loadExistingData() {
    final data = widget.existingData ?? widget.step.responseData;
    if (data == null || data.isEmpty) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>?;
      if (map == null) return;
      final list = map['selectedOptions'];
      if (list is List) {
        for (final item in list) {
          _selectedKeys.add(item.toString());
        }
      }
    } catch (_) {}
  }

  void _toggle(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
    _reportData();
  }

  void _reportData() {
    ref.read(onboardingViewModelProvider.notifier)
        .updateStepData({'selectedOptions': _selectedKeys.toList()});
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
            widget.step.title ?? 'Select options',
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
            final key = option.optionKey ?? option.optionId?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingOptionCard(
                label: option.label ?? option.optionKey ?? '',
                description: option.description,
                iconUrl: option.iconUrl,
                isSelected: _selectedKeys.contains(key),
                onTap: () => _toggle(key),
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
