package com.dev.backend.model.enums;

/**
 * Types of notifications for the gym plan application (UC-15)
 */
public enum NotificationType {
    WORKOUT_REMINDER("Workout Reminder", "Reminder for upcoming scheduled workout"),
    STREAK("Streak Celebration", "Celebration for workout consistency"),
    GOAL_PROGRESS("Goal Progress", "Milestone update on fitness goal progress"),
    MISSED_WORKOUT("Missed Workout", "Notification when a scheduled workout was missed");

    private final String displayName;
    private final String description;

    NotificationType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }
}
