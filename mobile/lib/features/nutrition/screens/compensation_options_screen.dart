import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../models/nutrition_requests.dart';
import '../viewmodels/nutrition_cheat_meals_viewmodel.dart';

class CompensationOptionsScreen extends ConsumerWidget {
  final int cheatMealLogId;

  const CompensationOptionsScreen({
    super.key,
    required this.cheatMealLogId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionCheatMealsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compensation options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: state.maybeWhen(
          loaded: (cheatMeals, options) {
            final optionsForView = options;
            if (optionsForView.isEmpty) {
              return const Center(
                child: Text('No options available'),
              );
            }
            return ListView.separated(
              itemCount: optionsForView.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spacing8),
              itemBuilder: (context, index) {
                final option = optionsForView[index];
                return ListTile(
                  title: Text(option.actionType),
                  subtitle: Text(option.actionDescription),
                  trailing: ElevatedButton(
                    onPressed: () {
                      final dto = SelectCompensationRequestDto(
                        compensationType: option.compensationType!,
                      );
                      ref
                          .read(
                            nutritionCheatMealsViewModelProvider.notifier,
                          )
                          .selectCompensation(cheatMealLogId, dto);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Select'),
                  ),
                );
              },
            );
          },
          orElse: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

