import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../exercises/models/exercise_filter.dart';
import '../../../exercises/models/exercise_models.dart';
import '../../../exercises/repositories/exercise_repository.dart';
import '../../viewmodels/create_workout_plan_state.dart';
import '../../../../ui/core/states/empty_screen.dart';

/// Bottom sheet for searching and selecting exercises
class ExercisePickerSheet extends ConsumerStatefulWidget {
  final ValueChanged<ExerciseDraft> onExerciseSelected;

  const ExercisePickerSheet({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState
    extends ConsumerState<ExercisePickerSheet> {
  static const _pageSize = 10;

  final _searchController = TextEditingController();
  List<ExerciseSummary> _exercises = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises({String? name}) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _hasMore = true;
      _currentQuery = name;
      _exercises = [];
    });
    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final filter = name != null && name.isNotEmpty
          ? ExerciseFilter(searchQuery: name)
          : null;
      final pageData = await repo.browseExercises(
        filter: filter,
        page: 0,
        size: _pageSize,
      );
      if (mounted) {
        setState(() {
          _exercises = pageData.content;
          _hasMore = !pageData.last;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final filter = _currentQuery != null && _currentQuery!.isNotEmpty
          ? ExerciseFilter(searchQuery: _currentQuery)
          : null;
      final pageData = await repo.browseExercises(
        filter: filter,
        page: nextPage,
        size: _pageSize,
      );
      if (mounted) {
        setState(() {
          _exercises.addAll(pageData.content);
          _currentPage = nextPage;
          _hasMore = !pageData.last;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onSearch(String query) {
    _loadExercises(name: query.isNotEmpty ? query : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        // Attach scroll listener for load-more
        scrollController.addListener(() {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent * 0.8) {
            _loadMore();
          }
        });

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXLarge),
              topRight: Radius.circular(AppDimensions.radiusXLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Exercise',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusRound),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing16,
                          vertical: AppDimensions.spacing12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.error, size: 48),
                                const SizedBox(
                                    height: AppDimensions.spacing8),
                                Text('Failed to load exercises'),
                                TextButton(
                                  onPressed: () => _loadExercises(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _exercises.isEmpty
                            ? const EmptyScreen(
                                illustrationHeight: 120,
                                title: 'No exercises found',
                                description: 'Try adjusting your search query',
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _exercises.length + (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Loading indicator at the bottom
                                  if (index == _exercises.length) {
                                    return Padding(
                                      padding: const EdgeInsets.all(
                                          AppDimensions.spacing16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final exercise = _exercises[index];
                                  return _ExerciseListTile(
                                    exercise: exercise,
                                    onTap: () {
                                      widget.onExerciseSelected(
                                        ExerciseDraft(
                                          exerciseId: exercise.exerciseId,
                                          exerciseName: exercise.exerciseName,
                                          imageUrl: exercise.imageUrl,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  final ExerciseSummary exercise;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey100),
          ),
        ),
        child: Row(
          children: [
            // Exercise icon/image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: exercise.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                      child: Image.network(
                        exercise.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            const SizedBox(width: AppDimensions.spacing12),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _buildTag(exercise.exerciseType),
                      const SizedBox(width: AppDimensions.spacing4),
                      _buildTag(exercise.difficultyLevel),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.add_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        _formatEnum(text),
        style: TextStyle(
          fontSize: 10,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  String _formatEnum(String value) {
    return value
        .split('_')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : w)
        .join(' ');
  }
}
