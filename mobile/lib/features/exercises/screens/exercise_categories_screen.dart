import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../viewmodels/exercise_categories_state.dart';
import '../viewmodels/exercise_categories_viewmodel.dart';
import '../widgets/exercise_category_card.dart';

/// Screen that shows exercise categories (muscle groups) for a given exercise type.
/// Tapping a category navigates to the exercise list filtered by that category.
class ExerciseCategoriesScreen extends ConsumerStatefulWidget {
  final String typeName;

  const ExerciseCategoriesScreen({
    super.key,
    required this.typeName,
  });

  @override
  ConsumerState<ExerciseCategoriesScreen> createState() =>
      _ExerciseCategoriesScreenState();
}

class _ExerciseCategoriesScreenState
    extends ConsumerState<ExerciseCategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseCategoriesViewModelProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTypeName(String typeName) {
    if (typeName.isEmpty) return typeName;
    return typeName[0].toUpperCase() + typeName.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseCategoriesViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '${_formatTypeName(widget.typeName)} Categories',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search categories',
                hintStyle: TextStyle(color: AppColors.grey400),
                prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16,
                  vertical: AppDimensions.spacing12,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacing8),

          // Content
          Expanded(
            child: state.when(
              initial: () => const Center(
                child: Text('Loading categories...'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (categories) {
                // Filter categories by search query
                final filteredCategories = _searchQuery.isEmpty
                    ? categories
                    : categories
                        .where((c) => c.categoryName
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                if (filteredCategories.isEmpty) {
                  return const EmptyScreen(
                    title: 'No categories found',
                    description: 'Try a different search term',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(exerciseCategoriesViewModelProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacing24,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return ExerciseCategoryCard(
                        category: category,
                        onTap: () {
                          // Navigate to exercises filtered by this category
                          context.push(
                            '/exercises/type/${widget.typeName}/category/${category.categoryName}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
              error: (message) => ErrorState(
                message: message,
                onRetry: () => ref
                    .read(exerciseCategoriesViewModelProvider.notifier)
                    .loadCategories(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
