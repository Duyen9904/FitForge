import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../viewmodels/exercise_types_state.dart';
import '../viewmodels/exercise_types_viewmodel.dart';
import '../widgets/exercise_type_card.dart';

/// Exercise Categories Screen
/// Shows exercise types with counts. Tap a type to see exercises of that type.
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _difficulties = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseTypesViewModelProvider.notifier).loadTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseTypesViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
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

          // Difficulty filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing4,
            ),
            child: state.maybeWhen(
              loaded: (types, selectedDifficulty) =>
                  _buildDifficultyChips(selectedDifficulty),
              orElse: () => _buildDifficultyChips(null),
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
              loaded: (types, selectedDifficulty) {
                // Filter types by search query
                final filteredTypes = _searchQuery.isEmpty
                    ? types
                    : types
                        .where((t) => t.typeName
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                if (filteredTypes.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No categories found',
                    description: 'Try a different search term',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(exerciseTypesViewModelProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacing24,
                    ),
                    itemCount: filteredTypes.length,
                    itemBuilder: (context, index) {
                      final type = filteredTypes[index];
                      return ExerciseTypeCard(
                        exerciseType: type,
                        onTap: () {
                          context.push(
                            '/exercises/type/${type.typeName}',
                            extra: selectedDifficulty,
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
                    .read(exerciseTypesViewModelProvider.notifier)
                    .loadTypes(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChips(String? selectedDifficulty) {
    return Row(
      children: _difficulties.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: FilterChip(
            label: Text(
              difficulty,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.grey700,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              ref
                  .read(exerciseTypesViewModelProvider.notifier)
                  .selectDifficulty(difficulty);
            },
            backgroundColor: AppColors.white,
            selectedColor: AppColors.grey800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              side: BorderSide(
                color: isSelected ? AppColors.grey800 : AppColors.grey300,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing6,
            ),
          ),
        );
      }).toList(),
    );
  }
}
