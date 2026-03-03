import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Displays the "Next Movement" label with current/total count,
/// the upcoming exercise name, and an optional thumbnail preview.
/// Wrapped in a glassmorphic container with slide-up entrance animation.
class RestNextMovementInfo extends StatefulWidget {
  final String nextExerciseName;
  final int currentIndex;
  final int totalExercises;
  final String? nextImageUrl;

  const RestNextMovementInfo({
    super.key,
    required this.nextExerciseName,
    required this.currentIndex,
    required this.totalExercises,
    this.nextImageUrl,
  });

  @override
  State<RestNextMovementInfo> createState() => _RestNextMovementInfoState();
}

class _RestNextMovementInfoState extends State<RestNextMovementInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    // Start animation after a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Thumbnail preview
                    if (widget.nextImageUrl != null) ...[
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        child: Container(
                          width: 56,
                          height: 56,
                          color: AppColors.white.withValues(alpha: 0.15),
                          child: Image.network(
                            widget.nextImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildThumbnailPlaceholder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                    ] else ...[
                      _buildThumbnailPlaceholder(),
                      const SizedBox(width: AppDimensions.spacing12),
                    ],

                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'NEXT UP · ${widget.currentIndex}/${widget.totalExercises}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      fontSize: 11,
                                    ),
                          ),
                          const SizedBox(height: AppDimensions.spacing4),
                          Text(
                            widget.nextExerciseName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Forward arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        color: AppColors.white.withValues(alpha: 0.15),
      ),
      child: Icon(
        Icons.fitness_center,
        color: AppColors.white.withValues(alpha: 0.5),
        size: 24,
      ),
    );
  }
}
