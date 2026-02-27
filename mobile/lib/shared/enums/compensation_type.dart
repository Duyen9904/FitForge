import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CompensationType {
  @JsonValue('ADD_CARDIO')
  addCardio,
  @JsonValue('REDUCE_CALORIES')
  reduceCalories,
  @JsonValue('COMBINATION')
  combination,
  @JsonValue('DO_NOTHING')
  doNothing;

  String get displayName {
    switch (this) {
      case CompensationType.addCardio:
        return 'Add cardio';
      case CompensationType.reduceCalories:
        return 'Reduce calories';
      case CompensationType.combination:
        return 'Combination';
      case CompensationType.doNothing:
        return 'Do nothing';
    }
  }
}

