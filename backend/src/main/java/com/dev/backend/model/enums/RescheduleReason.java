package com.dev.backend.model.enums;

/**
 * High-level trigger/origin for rescheduling a workout session.
 *
 * This is intentionally separate from {@link MissedWorkoutReason}, which captures
 * why the user missed the original session (UC-6.1). {@code RescheduleReason}
 * describes what initiated the change in schedule itself, regardless of whether
 * the session was already missed or still in the future.
 *
 * Typical mappings:
 * - USER_INITIATED  -> User proactively adjusted their schedule.
 * - MISSED_WORKOUT  -> Reschedule performed as part of missed-workout handling (UC-6.3).
 * - SYSTEM_DEFAULT  -> Automatic/system-driven adjustment (e.g. algorithmic optimization).
 */
public enum RescheduleReason {
    USER_INITIATED,
    MISSED_WORKOUT,
    SYSTEM_DEFAULT
}

