import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Loading placeholder for an async form field
class FormLoadingField extends StatelessWidget {
  final String label;

  const FormLoadingField({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Error placeholder for a failed async form field
class FormErrorField extends StatelessWidget {
  final String label;
  final String error;

  const FormErrorField({
    super.key,
    required this.label,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              'Failed to load',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
