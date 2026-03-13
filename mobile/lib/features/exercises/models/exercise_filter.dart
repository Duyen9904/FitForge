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
    String? searchQuery,
    bool? requiresSpotter,
    bool? favoritesOnly,
    bool? recentlyUsed,
    // External API pass-through fields (ExerciseDB v2)
    String? targetMuscles,   // comma-separated muscle names
    String? bodyParts,       // comma-separated body part names
    String? equipments,      // comma-separated equipment names
    String? keywords,        // comma-separated keywords
    String? after,           // cursor for forward pagination
    String? before,          // cursor for backward pagination
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
    // External API pass-through params
    if (targetMuscles != null && targetMuscles!.isNotEmpty) {
      params['targetMuscles'] = targetMuscles;
    }
    if (bodyParts != null && bodyParts!.isNotEmpty) {
      params['bodyParts'] = bodyParts;
    }
    if (equipments != null && equipments!.isNotEmpty) {
      params['equipments'] = equipments;
    }
    if (keywords != null && keywords!.isNotEmpty) {
      params['keywords'] = keywords;
    }
    if (after != null && after!.isNotEmpty) {
      params['after'] = after;
    }
    if (before != null && before!.isNotEmpty) {
      params['before'] = before;
    }

    return params;
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return (muscleGroupIds != null && muscleGroupIds!.isNotEmpty) ||
        (equipmentIds != null && equipmentIds!.isNotEmpty) ||
        difficultyLevel != null ||
        exerciseType != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        requiresSpotter != null ||
        favoritesOnly == true ||
        recentlyUsed == true ||
        (targetMuscles != null && targetMuscles!.isNotEmpty) ||
        (bodyParts != null && bodyParts!.isNotEmpty) ||
        (equipments != null && equipments!.isNotEmpty) ||
        (keywords != null && keywords!.isNotEmpty);
  }

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (muscleGroupIds != null && muscleGroupIds!.isNotEmpty) count++;
    if (equipmentIds != null && equipmentIds!.isNotEmpty) count++;
    if (difficultyLevel != null) count++;
    if (exerciseType != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (requiresSpotter != null) count++;
    if (favoritesOnly == true) count++;
    if (recentlyUsed == true) count++;
    if (targetMuscles != null && targetMuscles!.isNotEmpty) count++;
    if (bodyParts != null && bodyParts!.isNotEmpty) count++;
    if (equipments != null && equipments!.isNotEmpty) count++;
    if (keywords != null && keywords!.isNotEmpty) count++;
    return count;
  }
}
