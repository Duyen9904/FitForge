import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/exercise_type_response.dart';

part 'exercise_types_state.freezed.dart';

/// State for exercise types / categories screen
@freezed
class ExerciseTypesState with _$ExerciseTypesState {
  const factory ExerciseTypesState.initial() = ExerciseTypesInitial;

  const factory ExerciseTypesState.loading() = ExerciseTypesLoading;

  const factory ExerciseTypesState.loaded({
    required List<ExerciseTypeResponse> types,
    String? selectedDifficulty,
  }) = ExerciseTypesLoaded;

  const factory ExerciseTypesState.error(String message) = ExerciseTypesError;
}
