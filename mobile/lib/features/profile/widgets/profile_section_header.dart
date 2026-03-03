import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';

/// Section header for grouping menu items in the profile screen.
class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: AppDimensions.spacing16,
            right: AppDimensions.spacing16,
            top: AppDimensions.spacing24,
            bottom: AppDimensions.spacing8,
          ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
