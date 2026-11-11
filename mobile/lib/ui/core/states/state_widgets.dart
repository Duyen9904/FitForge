import 'package:flutter/material.dart';
export 'empty_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'empty_screen.dart';

/// Custom empty state widget - delegates to [EmptyScreen] for consistent illustration and styling.
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;
  final String? illustrationPath;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.illustration,
    this.illustrationPath,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyScreen(
      title: title,
      description: description,
      buttonText: actionText,
      onButtonPressed: onAction,
      illustration: illustration,
      illustrationPath: illustrationPath,
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacing24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
