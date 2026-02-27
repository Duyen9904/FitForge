package com.dev.backend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Utility service for calculating workout session dates based on plan parameters.
 * Distributes sessions evenly across weeks according to frequency per week.
 */
@Service
@Slf4j
public class WorkoutDateCalculator {

    /**
     * Calculate scheduled dates for all sessions in a workout plan.
     * Sessions are distributed evenly throughout each week based on the frequency per week.
     *
     * @param startDate The start date of the workout plan
     * @param totalSessions Total number of sessions to schedule
     * @param frequencyPerWeek Number of workout sessions per week
     * @return List of LocalDate objects representing the scheduled date for each session
     */
    public List<LocalDate> calculateSessionDates(LocalDate startDate, int totalSessions, int frequencyPerWeek) {
        log.debug("Calculating session dates: startDate={}, totalSessions={}, frequencyPerWeek={}",
                startDate, totalSessions, frequencyPerWeek);

        List<LocalDate> dates = new ArrayList<>();
        List<Integer> weeklyPattern = distributeSessionsInWeek(frequencyPerWeek);
        
        int sessionIndex = 0;
        int weekNumber = 0;

        while (sessionIndex < totalSessions) {
            for (int dayOffset : weeklyPattern) {
                if (sessionIndex >= totalSessions) {
                    break;
                }
                int absoluteDays = (weekNumber * 7) + dayOffset;
                LocalDate sessionDate = startDate.plusDays(absoluteDays);
                dates.add(sessionDate);
                sessionIndex++;
            }
            weekNumber++;
        }

        log.debug("Calculated {} session dates", dates.size());
        return dates;
    }

    /**
     * Distribute workout sessions evenly across a 7-day week.
     * Returns day offsets (0-6) representing which days of the week should have sessions.
     *
     * Examples:
     * - frequency=3 → [0, 2, 5] (Mon, Wed, Sat)
     * - frequency=4 → [0, 2, 4, 6] (Mon, Wed, Fri, Sun)
     * - frequency=5 → [0, 1, 3, 4, 6] (Mon, Tue, Thu, Fri, Sun)
     *
     * @param frequencyPerWeek Number of sessions per week
     * @return List of day offsets (0=Monday to 6=Sunday)
     */
    private List<Integer> distributeSessionsInWeek(int frequencyPerWeek) {
        List<Integer> pattern = new ArrayList<>();
        
        if (frequencyPerWeek <= 0 || frequencyPerWeek > 7) {
            log.warn("Invalid frequency per week: {}. Defaulting to 3 sessions per week.", frequencyPerWeek);
            frequencyPerWeek = 3;
        }

        if (frequencyPerWeek == 7) {
            // Every day
            for (int i = 0; i < 7; i++) {
                pattern.add(i);
            }
        } else if (frequencyPerWeek == 1) {
            // Once per week - Monday
            pattern.add(0);
        } else {
            // Distribute sessions evenly across the week
            double interval = 7.0 / frequencyPerWeek;
            for (int i = 0; i < frequencyPerWeek; i++) {
                int dayOffset = (int) Math.round(i * interval);
                // Ensure we don't exceed day 6 (Sunday)
                dayOffset = Math.min(dayOffset, 6);
                pattern.add(dayOffset);
            }
        }

        log.debug("Weekly distribution pattern for frequency {}: {}", frequencyPerWeek, pattern);
        return pattern;
    }

    /**
     * Calculate the scheduled date for a specific session based on its day number.
     * Useful for on-demand session generation.
     *
     * @param startDate The start date of the workout plan
     * @param dayNumber The day number of the session (1-indexed)
     * @param frequencyPerWeek Number of workout sessions per week
     * @return The scheduled date for the session
     */
    public LocalDate calculateDateForDayNumber(LocalDate startDate, int dayNumber, int frequencyPerWeek) {
        if (dayNumber <= 0) {
            log.warn("Invalid day number: {}. Returning start date.", dayNumber);
            return startDate;
        }

        List<Integer> weeklyPattern = distributeSessionsInWeek(frequencyPerWeek);
        
        // Convert dayNumber (1-indexed) to 0-indexed
        int sessionIndex = dayNumber - 1;
        
        int weekNumber = sessionIndex / frequencyPerWeek;
        int sessionInWeek = sessionIndex % frequencyPerWeek;
        
        int dayOffset = weeklyPattern.get(sessionInWeek);
        int absoluteDays = (weekNumber * 7) + dayOffset;
        
        return startDate.plusDays(absoluteDays);
    }
}
