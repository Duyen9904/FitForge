import 'package:json_annotation/json_annotation.dart';

/// Target muscle group for workouts
@JsonEnum(valueField: 'value')
enum TargetMuscleGroup {
  @JsonValue('BACK')
  back('BACK'),
  @JsonValue('CHEST')
  chest('CHEST'),
  @JsonValue('ARMS')
  arms('ARMS'),
  @JsonValue('LEGS')
  legs('LEGS'),
  @JsonValue('GLUTES')
  glutes('GLUTES'),
  @JsonValue('SHOULDERS')
  shoulders('SHOULDERS'),
  @JsonValue('CORE')
  core('CORE'),
  @JsonValue('FULL_BODY')
  fullBody('FULL_BODY');

  final String value;
  const TargetMuscleGroup(this.value);

  String get displayName {
    switch (this) {
      case TargetMuscleGroup.back:
        return 'Back';
      case TargetMuscleGroup.chest:
        return 'Chest';
      case TargetMuscleGroup.arms:
        return 'Arms';
      case TargetMuscleGroup.legs:
        return 'Legs';
      case TargetMuscleGroup.glutes:
        return 'Glutes';
      case TargetMuscleGroup.shoulders:
        return 'Shoulders';
      case TargetMuscleGroup.core:
        return 'Core';
      case TargetMuscleGroup.fullBody:
        return 'Full Body';
    }
  }
}
