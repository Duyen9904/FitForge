/// Notification type matching backend NotificationType enum
enum NotificationType {
  workoutReminder('WORKOUT_REMINDER', 'Workout Reminder'),
  streak('STREAK', 'Streak Celebration'),
  goalProgress('GOAL_PROGRESS', 'Goal Progress'),
  missedWorkout('MISSED_WORKOUT', 'Missed Workout');

  final String apiValue;
  final String displayName;

  const NotificationType(this.apiValue, this.displayName);

  /// Parse from backend API string value
  factory NotificationType.fromApi(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => NotificationType.workoutReminder,
    );
  }
}
