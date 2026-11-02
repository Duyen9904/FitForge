import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Top App Bar for the Home screen using the app's resource system colors.
/// - Left: User avatar (tap to go to profile)
/// - Right: Search exercises, AI Plan Generation button, and Notifications
class HomeTopBar extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onGeneratePlan;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  const HomeTopBar({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.onGeneratePlan,
    this.onSearchTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      children: [
        // 1. Profile Avatar (Left)
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(0.15),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // 2. Action Icons (Right)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Icon
            if (onSearchTap != null)
              IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.grey700,
                  size: 24,
                ),
                onPressed: onSearchTap,
                tooltip: 'Search exercises',
              ),

            // AI-Generated Plan Icon Button (using AppColors.primaryGradient)
            if (onGeneratePlan != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    onTap: onGeneratePlan,
                    child: const Padding(
                      padding: EdgeInsets.all(AppDimensions.spacing8),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Notifications Icon
            if (onNotificationsTap != null)
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.grey700,
                  size: 24,
                ),
                onPressed: onNotificationsTap,
                tooltip: 'Notifications',
              ),
          ],
        ),
      ],
    );
  }
}
