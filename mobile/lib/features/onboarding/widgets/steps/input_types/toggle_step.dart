import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/onboarding_response.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';

/// Generic TOGGLE step - one boolean per option from step.options.
/// Calls the ViewModel directly via Riverpod on user interaction.
class ToggleStep extends ConsumerStatefulWidget {
  final OnboardingStepResponse step;
  final String? existingData;

  const ToggleStep({
    super.key,
    required this.step,
    this.existingData,
  });

  @override
  ConsumerState<ToggleStep> createState() => _ToggleStepState();
}

class _ToggleStepState extends ConsumerState<ToggleStep> {
  final Map<String, bool> _values = {};

  @override
  void initState() {
    super.initState();
    _initFromOptions();
    _loadExistingData();
    // Toggle data is always valid — report immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportData();
    });
  }

  void _initFromOptions() {
    for (final opt in widget.step.options) {
      final key = opt.optionKey ?? opt.optionId?.toString() ?? opt.label ?? '';
      if (key.isNotEmpty) _values[key] = true;
    }
  }

  void _loadExistingData() {
    final data = widget.existingData ?? widget.step.responseData;
    if (data == null || data.isEmpty) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>?;
      if (map == null) return;
      for (final entry in map.entries) {
        if (_values.containsKey(entry.key) && entry.value is bool) {
          _values[entry.key] = entry.value as bool;
        }
      }
    } catch (_) {}
  }

  void _reportData() {
    ref.read(onboardingViewModelProvider.notifier)
        .updateStepData(Map<String, dynamic>.from(_values));
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
            widget.step.title ?? 'Preferences',
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
          const SizedBox(height: 32),
          ...options.map((option) {
            final key = option.optionKey ?? option.optionId?.toString() ?? option.label ?? '';
            final value = _values[key] ?? true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildToggleTile(
                theme: theme,
                icon: Icons.tune,
                title: option.label ?? option.optionKey ?? '',
                subtitle: option.description,
                value: value,
                onChanged: (v) {
                  setState(() => _values[key] = v);
                  _reportData();
                },
              ),
            );
          }),
          if (widget.step.helpText != null) ...[
            const SizedBox(height: 24),
            _buildHelpText(theme, widget.step.helpText!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: value
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
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
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
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
