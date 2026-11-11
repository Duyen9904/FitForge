import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../viewmodels/exercise_types_viewmodel.dart';
import 'exercise_type_card.dart';

/// Content widget for the Categories tab in the Exercise Library.
/// Displays a filterable list of exercise type cards.
class CategoriesTabContent extends ConsumerWidget {
  const CategoriesTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseTypesViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: Text('Loading categories...'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (types, selectedDifficulty) {
        if (types.isEmpty) {
          return const EmptyScreen(
            title: 'No categories found',
            description: 'No categories available',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(exerciseTypesViewModelProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spacing24,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
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
        onRetry: () =>
            ref.read(exerciseTypesViewModelProvider.notifier).loadTypes(),
      ),
    );
  }
}
