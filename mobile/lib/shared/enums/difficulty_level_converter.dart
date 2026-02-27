import 'package:freezed_annotation/freezed_annotation.dart';
import 'difficulty_level.dart';

/// JSON converter for DifficultyLevel that handles case-insensitive deserialization
class DifficultyLevelConverter implements JsonConverter<DifficultyLevel?, String?> {
  const DifficultyLevelConverter();

  @override
  DifficultyLevel? fromJson(String? json) {
    if (json == null) return null;
    return DifficultyLevel.fromString(json);
  }

  @override
  String? toJson(DifficultyLevel? object) {
    return object?.name;
  }
}
