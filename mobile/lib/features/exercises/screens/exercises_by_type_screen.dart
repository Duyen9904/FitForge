import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_filter.dart';
import '../viewmodels/exercise_list_state.dart';
import '../viewmodels/exercise_list_viewmodel.dart';
import '../widgets/exercise_list_item.dart';

/// Screen that shows exercises filtered by a specific type/category.
/// Displays exercises in a list view with image, name, and chevron.
class ExercisesByTypeScreen extends ConsumerStatefulWidget {
  final String typeName;
  final String? categoryName;

  const ExercisesByTypeScreen({
    super.key,
    required this.typeName,
    this.categoryName,
  });

  @override
  ConsumerState<ExercisesByTypeScreen> createState() =>
      _ExercisesByTypeScreenState();
}

class _ExercisesByTypeScreenState
    extends ConsumerState<ExercisesByTypeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    final filter = ExerciseFilter(
      exerciseType: widget.typeName,
      muscleGroupCategory: widget.categoryName,
    );
    ref.read(exerciseListViewModelProvider.notifier).loadExercises(
          filter: filter,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(exerciseListViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(exerciseListViewModelProvider.notifier).refresh();
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(RegExp(r'[_\s]+'))
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseListViewModelProvider);
    final displayName = widget.categoryName != null
        ? _formatName(widget.categoryName!)
        : _formatName(widget.typeName);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          displayName,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Navigate to favorites
              context.push('/exercises/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open filter bottom sheet
            },
          ),
        ],
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
                hintText: 'Search',
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

          // Content
          Expanded(
            child: state.when(
              initial: () => const Center(
                child: Text('Loading exercises...'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (exercises, currentPage, totalPages, hasMore, filter) {
                // Filter by local search
                final filteredExercises = _searchQuery.isEmpty
                    ? exercises
                    : exercises
                        .where((e) => e.exerciseName
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                if (filteredExercises.isEmpty) {
                  return EmptyState(
                    icon: Icons.fitness_center,
                    title: 'No exercises found',
                    description: _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'No $displayName exercises available',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredExercises.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filteredExercises.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.spacing16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final exercise = filteredExercises[index];
                      return ExerciseListItem(
                        exercise: exercise,
                        onTap: () {
                          context.push(
                            '/exercises/${exercise.exerciseId}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loadingMore: (exercises, currentPage, filter) {
                // Filter by local search
                final filteredExercises = _searchQuery.isEmpty
                    ? exercises
                    : exercises
                        .where((e) => e.exerciseName
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredExercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= filteredExercises.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.spacing16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final exercise = filteredExercises[index];
                    return ExerciseListItem(
                      exercise: exercise,
                      onTap: () {
                        context.push(
                          '/exercises/${exercise.exerciseId}',
                        );
                      },
                    );
                  },
                );
              },
              error: (message) => ErrorState(
                message: message,
                onRetry: _loadExercises,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
