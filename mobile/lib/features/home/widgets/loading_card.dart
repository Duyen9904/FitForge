import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';

/// Generic loading card widget with optional message
class LoadingCard extends StatelessWidget {
  final String? message;

  const LoadingCard({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (message != null) ...[
              const SizedBox(width: AppDimensions.spacing12),
              Text(message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
