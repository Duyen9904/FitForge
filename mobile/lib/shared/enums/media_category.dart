import 'package:json_annotation/json_annotation.dart';

/// Categories for media uploads to GCP Cloud Storage.
enum MediaCategory {
  @JsonValue('PROGRESS_PHOTO')
  progressPhoto,

  @JsonValue('PROFILE_AVATAR')
  profileAvatar,

  @JsonValue('MEAL_PHOTO')
  mealPhoto,

  @JsonValue('EXERCISE_VIDEO')
  exerciseVideo,

  @JsonValue('INBODY_SCAN')
  inbodyScan,

  @JsonValue('MEAL_PROOF')
  mealProof,

  @JsonValue('WORKOUT_PROOF')
  workoutProof;

  /// The SCREAMING_SNAKE_CASE value expected by the API.
  String get value {
    switch (this) {
      case MediaCategory.progressPhoto:
        return 'PROGRESS_PHOTO';
      case MediaCategory.profileAvatar:
        return 'PROFILE_AVATAR';
      case MediaCategory.mealPhoto:
        return 'MEAL_PHOTO';
      case MediaCategory.exerciseVideo:
        return 'EXERCISE_VIDEO';
      case MediaCategory.inbodyScan:
        return 'INBODY_SCAN';
      case MediaCategory.mealProof:
        return 'MEAL_PROOF';
      case MediaCategory.workoutProof:
        return 'WORKOUT_PROOF';
    }
  }
}
