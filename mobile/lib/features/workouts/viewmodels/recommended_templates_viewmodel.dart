import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_plan_models.dart';
import '../repositories/workout_plan_repository.dart';

/// Provider for recommended workout templates
final recommendedWorkoutTemplatesProvider = FutureProvider.autoDispose<
    List<WorkoutTemplateSummaryResponse>>((ref) async {
  final repository = ref.watch(workoutPlanRepositoryProvider);

  try {
    return await repository.getRecommendedTemplates(limit: 5);
  } catch (e, stackTrace) {
    developer.log(
      'Failed to load recommended workout templates',
      name: 'recommendedWorkoutTemplatesProvider',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

