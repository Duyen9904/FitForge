import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum RescheduleReason {
  @JsonValue('USER_INITIATED')
  userInitiated,
  @JsonValue('MISSED_WORKOUT')
  missedWorkout,
  @JsonValue('SYSTEM_DEFAULT')
  systemDefault;

  String get displayName {
    switch (this) {
      case RescheduleReason.userInitiated:
        return 'User Initiated';
      case RescheduleReason.missedWorkout:
        return 'Missed Workout';
      case RescheduleReason.systemDefault:
        return 'System Default';
    }
  }
}
