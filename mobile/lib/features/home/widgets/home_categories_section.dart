import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../../exercises/viewmodels/exercise_categories_viewmodel.dart';

/// Horizontal scrollable categories section for the home screen.
/// Displays exercise muscle-group categories as compact vertical cards
/// with pastel backgrounds and representative icons.
class HomeCategoriesSection extends ConsumerStatefulWidget {
  const HomeCategoriesSection({super.key});

  @override
  ConsumerState<HomeCategoriesSection> createState() =>
      _HomeCategoriesSectionState();
}

class _HomeCategoriesSectionState extends ConsumerState<HomeCategoriesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(exerciseCategoriesViewModelProvider);
      state.maybeWhen(
        loaded: (_) => null, // already loaded
        orElse: () =>
            ref.read(exerciseCategoriesViewModelProvider.notifier).loadCategories(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseCategoriesViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
            ),
            GestureDetector(
              onTap: () => context.push(Routes.exercises),
              child: Text(
                'See all',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),

        // Horizontal list
        state.when(
          initial: () => _buildShimmerRow(),
          loading: () => _buildShimmerRow(),
          loaded: (categories) {
            if (categories.isEmpty) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.spacing12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final visual =
                      _getCategoryVisual(category.categoryName);
                  return _CategoryCard(
                    name: _formatName(category.categoryName),
                    icon: visual.icon,
                    backgroundColor: visual.bgColor,
                    iconColor: visual.iconColor,
                    onTap: () => context.push(Routes.exercises),
                  );
                },
              ),
            );
          },
          error: (_) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildShimmerRow() {
    return SizedBox(
      height: 140,
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i < 2 ? AppDimensions.spacing12 : 0,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusXLarge),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(RegExp(r'[_\s]+'))
        .map((w) =>
            w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  _CategoryVisual _getCategoryVisual(String name) {
    switch (name.toUpperCase()) {
      case 'CHEST':
        return _CategoryVisual(
          bgColor: const Color(0xFFFFE4EC),
          iconColor: const Color(0xFFC62828),
          icon: Icons.fitness_center,
        );
      case 'BACK':
        return _CategoryVisual(
          bgColor: const Color(0xFFE8E4F8),
          iconColor: AppColors.primaryDark,
          icon: Icons.straighten,
        );
      case 'SHOULDERS':
        return _CategoryVisual(
          bgColor: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE65100),
          icon: Icons.accessibility_new,
        );
      case 'LEGS':
        return _CategoryVisual(
          bgColor: const Color(0xFFE0F7FA),
          iconColor: const Color(0xFF00838F),
          icon: Icons.directions_walk,
        );
      case 'ARMS':
      case 'BICEPS':
      case 'TRICEPS':
        return _CategoryVisual(
          bgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          icon: Icons.sports_gymnastics,
        );
      case 'CORE':
      case 'ABS':
      case 'ABDOMINALS':
        return _CategoryVisual(
          bgColor: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFAD1457),
          icon: Icons.view_stream,
        );
      case 'GLUTES':
        return _CategoryVisual(
          bgColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF6A1B9A),
          icon: Icons.airline_seat_recline_extra,
        );
      case 'FULL_BODY':
      case 'FULL BODY':
        return _CategoryVisual(
          bgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1565C0),
          icon: Icons.person,
        );
      default:
        return _CategoryVisual(
          bgColor: AppColors.grey100,
          iconColor: AppColors.grey600,
          icon: Icons.sports,
        );
    }
  }
}

class _CategoryVisual {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  const _CategoryVisual({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon area
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            // Label
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
