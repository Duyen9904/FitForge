import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PlanMealStatus {
  @JsonValue('PLANNED')
  planned('PLANNED'),
  @JsonValue('COMPLETED')
  completed('COMPLETED'),
  @JsonValue('SKIPPED')
  skipped('SKIPPED');

  final String value;
  const PlanMealStatus(this.value);
}
