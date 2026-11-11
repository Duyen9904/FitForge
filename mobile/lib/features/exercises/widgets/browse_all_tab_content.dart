import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_filter.dart';
import '../repositories/exercise_repository.dart';
import '../viewmodels/exercise_list_state.dart';
import '../viewmodels/exercise_list_viewmodel.dart';
import '../widgets/difficulty_bottom_sheet.dart';
import '../widgets/exercise_list_item.dart';

/// Dedicated provider for the Browse All tab so it doesn't conflict
/// with the existing exerciseListViewModelProvider used by other screens.
final browseAllExerciseListViewModelProvider =
    StateNotifierProvider<ExerciseListViewModel, ExerciseListState>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseListViewModel(repository: repository);
});

/// Content widget for the "Browse All" tab in the Exercise Library.
/// Shows every exercise in a flat, paginated list with search,
/// difficulty filtering, infinite scroll, and pull-to-refresh.
class BrowseAllTabContent extends ConsumerStatefulWidget {
  const BrowseAllTabContent({super.key});

  @override
  ConsumerState<BrowseAllTabContent> createState() =>
      _BrowseAllTabContentState();
}

class _BrowseAllTabContentState extends ConsumerState<BrowseAllTabContent>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDifficulty;

  @override
  bool get wantKeepAlive => true;

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
      difficultyLevel: _selectedDifficulty,
    );
    ref.read(browseAllExerciseListViewModelProvider.notifier).loadExercises(
          filter: filter,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(browseAllExerciseListViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(browseAllExerciseListViewModelProvider.notifier).refresh();
  }

  void _onDifficultyChanged(String? difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _loadExercises();
  }

  Future<void> _showDifficultyBottomSheet() async {
    final result = await DifficultyBottomSheet.show(
      context,
      currentDifficulty: _selectedDifficulty,
    );
    if (!mounted) return;
    _onDifficultyChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(browseAllExerciseListViewModelProvider);

    return Column(
      children: [
        // Search bar + filter icon
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing8,
          ),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search exercises',
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

              const SizedBox(width: AppDimensions.spacing8),

              // Filter icon button
              GestureDetector(
                onTap: _showDifficultyBottomSheet,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedDifficulty != null
                        ? AppColors.primary
                        : AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius12),
                    border: Border.all(
                      color: _selectedDifficulty != null
                          ? AppColors.primary
                          : AppColors.grey200,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: _selectedDifficulty != null
                        ? AppColors.white
                        : AppColors.grey600,
                    size: 22,
                  ),
                ),
              ),
            ],
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
                return EmptyScreen(
                  title: 'No exercises found',
                  description: _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'No exercises available',
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
    );
  }
}
