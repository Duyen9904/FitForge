import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_dimensions.dart';

/// Card with icon and decimal input for a single measurement metric.
class MeasurementMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final String suffix;
  final String hint;
  final bool required;
  final String? Function(String?)? validator;

  const MeasurementMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.controller,
    required this.suffix,
    required this.hint,
    required this.required,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title + (required ? ' *' : ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: suffix,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
