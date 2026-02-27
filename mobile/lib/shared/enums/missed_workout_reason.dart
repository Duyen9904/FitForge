import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MissedWorkoutReason {
  @JsonValue('SICK_INJURED')
  sickInjured,
  @JsonValue('TOO_BUSY')
  tooBusy,
  @JsonValue('NO_MOTIVATION')
  noMotivation,
  @JsonValue('EQUIPMENT_UNAVAILABLE')
  equipmentUnavailable,
  @JsonValue('OTHER')
  other;

  String get displayName {
    switch (this) {
      case MissedWorkoutReason.sickInjured:
        return 'Sick / Injured';
      case MissedWorkoutReason.tooBusy:
        return 'Too Busy';
      case MissedWorkoutReason.noMotivation:
        return 'No Motivation';
      case MissedWorkoutReason.equipmentUnavailable:
        return 'Equipment Unavailable';
      case MissedWorkoutReason.other:
        return 'Other';
    }
  }
}
