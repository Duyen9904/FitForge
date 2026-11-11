import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_filter.dart';
import '../viewmodels/exercise_list_viewmodel.dart';
import '../widgets/exercise_card.dart';

/// UC-4.3: Favorites Screen
/// Display user's favorite exercises
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseListViewModelProvider.notifier).applyFilter(
            const ExerciseFilter(favoritesOnly: true),
          );
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(exerciseListViewModelProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Exercises'),
      ),
      body: state.when(
        initial: () => const Center(
          child: Text('Pull to load favorites'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loaded: (exercises, currentPage, totalPages, hasMore, filter) {
          if (exercises.isEmpty) {
            return EmptyScreen(
              title: 'No favorite exercises yet',
              description: 'Add exercises to favorites to see them here',
              buttonText: 'Browse Exercises',
              onButtonPressed: () => context.go('/exercises'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppDimensions.spacing12,
                mainAxisSpacing: AppDimensions.spacing12,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () {
                    context.push('/exercises/${exercise.exerciseId}');
                  },
                );
              },
            ),
          );
        },
        loadingMore: (exercises, currentPage, filter) {
          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppDimensions.spacing12,
              mainAxisSpacing: AppDimensions.spacing12,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExerciseCard(
                exercise: exercise,
                onTap: () {
                  context.push('/exercises/${exercise.exerciseId}');
                },
              );
            },
          );
        },
        error: (message) => ErrorState(
          message: message,
          onRetry: () => ref
              .read(exerciseListViewModelProvider.notifier)
              .applyFilter(const ExerciseFilter(favoritesOnly: true)),
        ),
      ),
    );
  }
}
