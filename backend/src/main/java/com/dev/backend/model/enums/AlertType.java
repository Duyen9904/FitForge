package com.dev.backend.model.enums;

/**
 * Types of recovery alerts for overtraining detection (UC-9.3)
 */
public enum AlertType {
    SLEEP_DEBT("Sleep Debt", "Insufficient sleep accumulated over multiple days"),
    HIGH_STRESS("High Stress", "Elevated stress levels sustained over extended period"),
    PERSISTENT_SORENESS("Persistent Soreness", "Muscle soreness not recovering as expected"),
    DECLINING_PERFORMANCE("Declining Performance", "Workout performance trending downward"),
    OVERTRAINING("Overtraining Warning", "Multiple warning signs detected - rest recommended"),
    LOW_ENERGY("Low Energy", "Energy levels consistently below optimal");

    private final String displayName;
    private final String description;

    AlertType(String displayName, String description) {
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
