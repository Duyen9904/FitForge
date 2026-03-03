import 'package:json_annotation/json_annotation.dart';

/// Onboarding step type - matches backend OnboardingStepType enum
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OnboardingStepType {
  /// Text inputs for name, DOB, gender
  personalInfo,

  /// Numeric inputs for weight, height
  bodyMetrics,

  /// Single select from admin-configured fitness level options
  fitnessLevel,

  /// Single/multi select from admin-configured fitness goal options
  fitnessGoal,

  /// Multi-select from admin-configured equipment options
  equipment,

  /// Multi-select days, select duration/time preferences
  schedule,

  /// Multi-select from admin-configured health limitation options
  healthLimitations,

  /// Toggle switches for each notification type
  notifications,

  /// Gender selection step
  gender,

  /// Age input step
  age,

  /// Weight input step
  weight,

  /// Height input step
  height;

  String get displayName {
    switch (this) {
      case OnboardingStepType.personalInfo:
        return 'Personal Info';
      case OnboardingStepType.bodyMetrics:
        return 'Body Metrics';
      case OnboardingStepType.fitnessLevel:
        return 'Fitness Level';
      case OnboardingStepType.fitnessGoal:
        return 'Fitness Goal';
      case OnboardingStepType.equipment:
        return 'Equipment';
      case OnboardingStepType.schedule:
        return 'Schedule';
      case OnboardingStepType.healthLimitations:
        return 'Health Limitations';
      case OnboardingStepType.notifications:
        return 'Notifications';
      case OnboardingStepType.gender:
        return 'Gender';
      case OnboardingStepType.age:
        return 'Age';
      case OnboardingStepType.weight:
        return 'Weight';
      case OnboardingStepType.height:
        return 'Height';
    }
  }
}
