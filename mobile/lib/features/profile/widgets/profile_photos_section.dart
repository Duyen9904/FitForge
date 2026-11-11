import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/profile_models.dart';
import '../../../ui/core/states/empty_screen.dart';

/// Check-in photos gallery section for the profile screen.
///
/// Displays workout proof photos in a horizontal scrollable list.
class ProfilePhotosSection extends StatelessWidget {
  final List<CheckInPhoto> photos;

  const ProfilePhotosSection({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spacing20,
        right: AppDimensions.spacing20,
        top: AppDimensions.spacing24,
        bottom: AppDimensions.spacing32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (photos.length > 4)
                TextButton(
                  onPressed: () {
                    // TODO: navigate to full gallery
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Show all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing12),

          // ── Photos Grid / Empty State ──
          if (photos.isEmpty) _buildEmptyState(theme) else _buildPhotosList(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPhotosList(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.spacing12),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoCard(photo: photo, theme: theme, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
        ),
      ),
      child: const EmptyScreen(
        illustrationHeight: 120,
        title: 'No check-in photos yet',
        description: 'Upload a photo when completing a workout',
      ),
    );
  }
}

/// Individual photo card in the horizontal list.
class _PhotoCard extends StatelessWidget {
  final CheckInPhoto photo;
  final ThemeData theme;
  final bool isDark;

  const _PhotoCard({
    required this.photo,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      child: SizedBox(
        width: 120,
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            if (photo.proofPhotoUrl != null &&
                photo.proofPhotoUrl!.isNotEmpty)
              Image.network(
                photo.proofPhotoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder();
                },
              )
            else
              _buildPlaceholder(),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Session name overlay
            Positioned(
              bottom: AppDimensions.spacing8,
              left: AppDimensions.spacing8,
              right: AppDimensions.spacing4,
              child: Text(
                photo.sessionName ?? 'Workout',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: isDark ? AppColors.grey700 : AppColors.grey200,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? AppColors.grey500 : AppColors.grey400,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: isDark ? AppColors.grey700 : AppColors.grey200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
