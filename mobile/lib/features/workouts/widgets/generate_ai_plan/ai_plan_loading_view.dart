import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Loading indicator shown while the AI generates a workout plan
class AIPlanLoadingView extends StatelessWidget {
  const AIPlanLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Generating your plan...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our AI is crafting a personalized\nworkout plan just for you',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
