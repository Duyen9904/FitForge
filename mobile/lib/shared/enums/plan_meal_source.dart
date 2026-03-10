import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PlanMealSource {
  @JsonValue('MANUAL')
  manual('MANUAL'),
  @JsonValue('TEMPLATE')
  template('TEMPLATE'),
  @JsonValue('RCM')
  rcm('RCM'),
  @JsonValue('AI')
  ai('AI');

  final String value;
  const PlanMealSource(this.value);
}
