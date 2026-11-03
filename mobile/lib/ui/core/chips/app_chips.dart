import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Reusable badge/tag chip following the app's design system colors and spacing.
class AppBadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const AppBadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.dotColor,
    this.foregroundColor = AppColors.primary,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing10,
      vertical: AppDimensions.spacing4,
    ),
    this.borderRadius = AppDimensions.radiusMedium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? foregroundColor.withOpacity(0.14);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: AppDimensions.spacing6),
          ] else if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing6),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}

/// Reusable segmented toggle control (e.g., Week | Month) using AppColors.
class AppSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final bool isDarkSurface;

  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
    this.isDarkSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing2),
      decoration: BoxDecoration(
        color: isDarkSurface
            ? AppColors.white.withOpacity(0.08)
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: isDarkSurface
              ? AppColors.white.withOpacity(0.1)
              : AppColors.grey200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selectedValue;
          return GestureDetector(
            onTap: () => onValueChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall + 2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                entry.value,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : (isDarkSurface ? AppColors.grey300 : AppColors.grey600),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Reusable selectable pill for cycle legends, week selectors, or filters.
class AppSelectablePill extends StatelessWidget {
  final String label;
  final String? trailingText;
  final Color? indicatorColor;
  final bool isSelected;
  final bool isDarkSurface;
  final VoidCallback onTap;

  const AppSelectablePill({
    super.key,
    required this.label,
    this.trailingText,
    this.indicatorColor,
    required this.isSelected,
    this.isDarkSurface = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (isDarkSurface
            ? AppColors.primary.withOpacity(0.22)
            : AppColors.primary.withOpacity(0.12))
        : (isDarkSurface
            ? AppColors.white.withOpacity(0.04)
            : AppColors.grey50);

    final borderColor = isSelected
        ? (isDarkSurface ? AppColors.primaryLight : AppColors.primary)
        : (isDarkSurface ? AppColors.white.withOpacity(0.08) : AppColors.grey200);

    final textColor = isSelected
        ? (isDarkSurface ? AppColors.white : AppColors.primaryDark)
        : (isDarkSurface ? AppColors.grey300 : AppColors.grey700);

    final trailingColor = isSelected
        ? (isDarkSurface ? AppColors.primaryLight : AppColors.primary)
        : (isDarkSurface ? AppColors.grey400 : AppColors.grey500);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing10,
          vertical: AppDimensions.spacing6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: borderColor, width: isSelected ? 1.2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (indicatorColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing6),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: AppDimensions.spacing6),
              Text(
                trailingText!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: trailingColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
