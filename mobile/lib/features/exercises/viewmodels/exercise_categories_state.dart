import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/exercise_category_response.dart';

part 'exercise_categories_state.freezed.dart';

/// State for exercise categories screen
@freezed
class ExerciseCategoriesState with _$ExerciseCategoriesState {
  const factory ExerciseCategoriesState.initial() = ExerciseCategoriesInitial;
  const factory ExerciseCategoriesState.loading() = ExerciseCategoriesLoading;
  const factory ExerciseCategoriesState.loaded({
    required List<ExerciseCategoryResponse> categories,
  }) = ExerciseCategoriesLoaded;
  const factory ExerciseCategoriesState.error(String message) =
      ExerciseCategoriesError;
}
