import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/exercise_filter.dart';
import '../models/exercise_models.dart';

part 'exercise_list_state.freezed.dart';

/// State for exercise list screen
@freezed
class ExerciseListState with _$ExerciseListState {
  const factory ExerciseListState.initial() = ExerciseListInitial;
  
  const factory ExerciseListState.loading() = ExerciseListLoading;
  
  const factory ExerciseListState.loaded({
    required List<ExerciseSummary> exercises,
    required int currentPage,
    required int totalPages,
    required bool hasMore,
    required ExerciseFilter activeFilter,
  }) = ExerciseListLoaded;
  
  const factory ExerciseListState.loadingMore({
    required List<ExerciseSummary> exercises,
    required int currentPage,
    required ExerciseFilter activeFilter,
  }) = ExerciseListLoadingMore;
  
  const factory ExerciseListState.error(String message) = ExerciseListError;
}
