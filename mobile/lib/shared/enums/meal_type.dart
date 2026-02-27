import 'package:json_annotation/json_annotation.dart';

/// Meal type for nutrition tracking
@JsonEnum()
enum MealType {
  @JsonValue('BREAKFAST')
  breakfast,
  @JsonValue('LUNCH')
  lunch,
  @JsonValue('DINNER')
  dinner,
  @JsonValue('SNACK')
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}
