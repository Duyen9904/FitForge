package com.dev.backend.model.enums;

/**
 * Status of compensation actions (UC-11)
 */
public enum CompensationStatus {
    PENDING("Pending", "Compensation created but not yet activated"),
    ACTIVE("Active", "Compensation is currently active"),
    COMPLETED("Completed", "Compensation successfully fulfilled"),
    EXPIRED("Expired", "Compensation period has passed without completion"),
    CANCELLED("Cancelled", "Compensation was cancelled by user");

    private final String displayName;
    private final String description;

    CompensationStatus(String displayName, String description) {
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
