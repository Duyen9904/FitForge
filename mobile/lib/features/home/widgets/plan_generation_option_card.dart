import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Individual option card widget for plan generation
class PlanGenerationOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final bool isRecommended;
  final VoidCallback onTap;

  const PlanGenerationOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isRecommended ? AppColors.primary : AppColors.grey300,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isRecommended
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.grey200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isRecommended ? AppColors.primary : AppColors.grey700,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing8,
                            vertical: AppDimensions.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            badgeText,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
