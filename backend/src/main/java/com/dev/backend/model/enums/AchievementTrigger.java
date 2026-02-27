package com.dev.backend.model.enums;

/**
 * Triggers for achievement awarding (UC-10.1)
 */
public enum AchievementTrigger {
    FIRST_WORKOUT("First Workout", 1),
    STREAK_7_DAYS("7-Day Streak", 7),
    STREAK_30_DAYS("30-Day Streak", 30),
    WORKOUTS_10("10 Workouts Completed", 10),
    WORKOUTS_50("50 Workouts Completed", 50),
    WORKOUTS_100("Century Club", 100),
    VOLUME_10000KG("Iron Pumper", 10000),
    ADHERENCE_80_PERCENT("Consistency King", 80),
    MEALS_7_DAYS("Nutrition Tracker", 7),
    MEALS_30_DAYS("Nutrition Ninja", 30),
    WEIGHT_GOAL_REACHED("Transformation", 0),
    RECOVERY_LOGGED_7_DAYS("Recovery Champion", 7),
    CALORIES_TARGET_MET_7_DAYS("Calorie Master", 7);

    private final String achievementName;
    private final int threshold;

    AchievementTrigger(String achievementName, int threshold) {
        this.achievementName = achievementName;
        this.threshold = threshold;
    }

    public String getAchievementName() {
        return achievementName;
    }

    public int getThreshold() {
        return threshold;
    }
}
