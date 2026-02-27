package com.dev.backend.model.enums;

/**
 * Options for making up a missed workout (UC-6.2)
 */
public enum MakeupOption {
    RESCHEDULE_NEXT_DAY,      // Reschedule entire session to next available day
    DISTRIBUTE_EXERCISES,      // Distribute missed exercises across upcoming sessions
    WEEKEND_MAKEUP,           // Add weekend makeup session
    EXTEND_PROGRAM            // Extend program by one week
}
