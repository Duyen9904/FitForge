package com.dev.backend.model.enums;

/**
 * Categories for achievements (UC-10)
 */
public enum AchievementCategory {
    WORKOUT("Workout", "Achievements related to workout completion"),
    NUTRITION("Nutrition", "Achievements related to nutrition tracking"),
    CONSISTENCY("Consistency", "Achievements for maintaining consistency"),
    STRENGTH("Strength", "Achievements for strength milestones"),
    MILESTONE("Milestone", "General milestone achievements"),
    TRANSFORMATION("Transformation", "Body transformation achievements");

    private final String displayName;
    private final String description;

    AchievementCategory(String displayName, String description) {
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
