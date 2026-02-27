import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_filter.freezed.dart';
part 'exercise_filter.g.dart';

/// Filter model for exercise browsing (UC-4.1)
/// Maps to backend ExerciseFilterRequest
@freezed
class ExerciseFilter with _$ExerciseFilter {
  const ExerciseFilter._();

  const factory ExerciseFilter({
    List<int>? muscleGroupIds,
    List<int>? equipmentIds,
    String? difficultyLevel,
    String? exerciseType,
    String? muscleGroupCategory,
    String? searchQuery,
    bool? requiresSpotter,
    bool? favoritesOnly,
    bool? recentlyUsed,
  }) = _ExerciseFilter;

  factory ExerciseFilter.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFilterFromJson(json);

  /// Convert filter to query parameters for API
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (muscleGroupIds != null && muscleGroupIds!.isNotEmpty) {
      params['muscleGroupIds'] = muscleGroupIds;
    }
    if (equipmentIds != null && equipmentIds!.isNotEmpty) {
      params['equipmentIds'] = equipmentIds;
    }
    if (difficultyLevel != null) {
      params['difficultyLevel'] = difficultyLevel;
    }
    if (exerciseType != null) {
      params['exerciseType'] = exerciseType;
    }
    if (muscleGroupCategory != null) {
      params['muscleGroupCategory'] = muscleGroupCategory;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['searchQuery'] = searchQuery;
    }
    if (requiresSpotter != null) {
      params['requiresSpotter'] = requiresSpotter;
    }
    if (favoritesOnly != null) {
      params['favoritesOnly'] = favoritesOnly;
    }
    if (recentlyUsed != null) {
      params['recentlyUsed'] = recentlyUsed;
    }

    return params;
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return (muscleGroupIds != null && muscleGroupIds!.isNotEmpty) ||
        (equipmentIds != null && equipmentIds!.isNotEmpty) ||
        difficultyLevel != null ||
        exerciseType != null ||
        muscleGroupCategory != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        requiresSpotter != null ||
        favoritesOnly == true ||
        recentlyUsed == true;
  }

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (muscleGroupIds != null && muscleGroupIds!.isNotEmpty) count++;
    if (equipmentIds != null && equipmentIds!.isNotEmpty) count++;
    if (difficultyLevel != null) count++;
    if (exerciseType != null) count++;
    if (muscleGroupCategory != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (requiresSpotter != null) count++;
    if (favoritesOnly == true) count++;
    if (recentlyUsed == true) count++;
    return count;
  }
}
