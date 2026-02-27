/// Notification type
enum NotificationType {
  workoutReminder,
  mealReminder,
  goalAchieved,
  progressUpdate,
  recoveryAlert,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.workoutReminder:
        return 'Workout Reminder';
      case NotificationType.mealReminder:
        return 'Meal Reminder';
      case NotificationType.goalAchieved:
        return 'Goal Achieved';
      case NotificationType.progressUpdate:
        return 'Progress Update';
      case NotificationType.recoveryAlert:
        return 'Recovery Alert';
      case NotificationType.general:
        return 'General';
    }
  }
}
