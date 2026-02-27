import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/exercise_models.dart';

part 'exercise_detail_state.freezed.dart';

/// State for exercise detail screen
@freezed
class ExerciseDetailState with _$ExerciseDetailState {
  const factory ExerciseDetailState.initial() = ExerciseDetailInitial;
  
  const factory ExerciseDetailState.loading() = ExerciseDetailLoading;
  
  const factory ExerciseDetailState.loaded({
    required Exercise exercise,
    required bool isFavorite,
    @Default(false) bool isTogglingFavorite,
  }) = ExerciseDetailLoaded;
  
  const factory ExerciseDetailState.error(String message) = ExerciseDetailError;
}
