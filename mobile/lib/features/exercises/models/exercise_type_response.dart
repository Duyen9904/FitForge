import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_type_response.freezed.dart';
part 'exercise_type_response.g.dart';

/// Exercise type with exercise count from GET /exercises/types
@freezed
class ExerciseTypeResponse with _$ExerciseTypeResponse {
  const factory ExerciseTypeResponse({
    required String typeName,
    required int exerciseCount,
  }) = _ExerciseTypeResponse;

  factory ExerciseTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTypeResponseFromJson(json);
}
