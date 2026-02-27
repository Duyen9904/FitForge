import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_category_response.freezed.dart';
part 'exercise_category_response.g.dart';

/// Exercise category with exercise count from GET /exercises/categories
@freezed
class ExerciseCategoryResponse with _$ExerciseCategoryResponse {
  const factory ExerciseCategoryResponse({
    required String categoryName,
    required int exerciseCount,
  }) = _ExerciseCategoryResponse;

  factory ExerciseCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ExerciseCategoryResponseFromJson(json);
}
