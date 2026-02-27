import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MakeupOption {
  @JsonValue('RESCHEDULE_NEXT_DAY')
  rescheduleNextDay,
  @JsonValue('DISTRIBUTE_EXERCISES')
  distributeExercises,
  @JsonValue('WEEKEND_MAKEUP')
  weekendMakeup,
  @JsonValue('EXTEND_PROGRAM')
  extendProgram;

  String get displayName {
    switch (this) {
      case MakeupOption.rescheduleNextDay:
        return 'Reschedule to Next Day';
      case MakeupOption.distributeExercises:
        return 'Distribute Exercises';
      case MakeupOption.weekendMakeup:
        return 'Weekend Makeup';
      case MakeupOption.extendProgram:
        return 'Extend Program';
    }
  }
}
