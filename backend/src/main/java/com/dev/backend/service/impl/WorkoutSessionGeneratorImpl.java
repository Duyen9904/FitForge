package com.dev.backend.service.impl;

import com.dev.backend.model.entity.Exercise;
import com.dev.backend.model.entity.SessionExercise;
import com.dev.backend.model.entity.WorkoutPlan;
import com.dev.backend.model.entity.WorkoutSession;
import com.dev.backend.service.WeightRecommendationService;
import com.dev.backend.service.WorkoutSessionGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkoutSessionGeneratorImpl implements WorkoutSessionGenerator {

    private final WeightRecommendationService weightRecommendationService;

    @Override
    public List<WorkoutSession> generateSessions(WorkoutPlan plan, List<Exercise> exercises, int startDay, int endDay) {
        log.info("Generating workout sessions for plan {}, days {}-{}", plan.getPlanId(), startDay, endDay);

        List<WorkoutSession> sessions = new ArrayList<>();
        
        for (int day = startDay; day <= endDay; day++) {
            WorkoutSession session = generateSessionForDay(plan, exercises, day);
            sessions.add(session);
        }

        return sessions;
    }

    @Override
    public WorkoutSession generateSessionForDay(WorkoutPlan plan, List<Exercise> exercises, int dayNumber) {
        log.info("Generating workout session for plan {}, day {}", plan.getPlanId(), dayNumber);

        WorkoutSession session = new WorkoutSession();
        session.setWorkoutPlan(plan);
        session.setDayNumber(dayNumber);

        // Determine if this is a rest day based on frequency
        int frequencyPerWeek = plan.getFrequencyPerWeek();
        boolean isRestDay = isRestDay(dayNumber, frequencyPerWeek);

        session.setIsRestDay(isRestDay);

        if (isRestDay) {
            session.setSessionName("Rest Day " + dayNumber);
            session.setFocusArea("Recovery");
            session.setEstimatedDuration(0);
            session.setWarmUpNotes("Light stretching and mobility work (optional)");
            session.setCoolDownNotes("Focus on recovery: hydration, nutrition, sleep");
            return session;
        }

        // Create workout session
        String goalType = plan.getGoal() != null ? plan.getGoal().getGoalName() : "GENERAL";
        String difficulty = plan.getDifficultyLevel();
        String targetMuscle = plan.getMuscleGroup().getGroupName();

        // Determine session focus based on day number
        String focusArea = determineFocusArea(dayNumber, frequencyPerWeek, targetMuscle);
        session.setSessionName("Day " + dayNumber + " - " + focusArea);
        session.setFocusArea(focusArea);

        // Set warm-up and cool-down notes
        session.setWarmUpNotes(getWarmUpNotes(focusArea));
        session.setCoolDownNotes(getCoolDownNotes());

        // Determine exercises per session based on goal
        int exercisesPerSession = calculateExercisesPerSession(goalType, difficulty);

        // Select exercises for this session
        List<Exercise> sessionExercises = selectExercisesForSession(exercises, exercisesPerSession, dayNumber);

        // Create SessionExercise entities
        List<SessionExercise> sessionExerciseList = new ArrayList<>();
        int orderIndex = 1;
        int totalDuration = 0;

        for (Exercise exercise : sessionExercises) {
            SessionExercise se = createSessionExercise(session, exercise, orderIndex, goalType, difficulty);
            sessionExerciseList.add(se);
            
            // Estimate duration: sets * (reps * 2 seconds + rest time)
            totalDuration += se.getSets() * (se.getRepetitions() * 2 + se.getRestTimeSeconds());
            orderIndex++;
        }

        // Add warm-up (10 min) and cool-down (10 min) to total duration
        session.setEstimatedDuration((totalDuration / 60) + 20);
        session.getSessionExercises().addAll(sessionExerciseList);

        return session;
    }

    // Helper: Determine if a day is a rest day
    private boolean isRestDay(int dayNumber, int frequencyPerWeek) {
        // Distribute rest days evenly throughout the week
        // For example, 3 days/week: Mon, Wed, Fri workouts (days 2, 4, 6, 7 are rest)
        // 4 days/week: Mon, Tue, Thu, Sat (days 3, 5, 7 are rest)
        // 5 days/week: Mon-Fri (days 6, 7 are rest)
        
        if (frequencyPerWeek >= 6) {
            // 6-7 days/week: only Sunday is rest
            return dayNumber == 7;
        } else if (frequencyPerWeek == 5) {
            // 5 days/week: Sat, Sun are rest
            return dayNumber == 6 || dayNumber == 7;
        } else if (frequencyPerWeek == 4) {
            // 4 days/week: Wed, Sat, Sun are rest
            return dayNumber == 3 || dayNumber == 6 || dayNumber == 7;
        } else if (frequencyPerWeek == 3) {
            // 3 days/week: workout days Mon(1), Wed(3), Sat(6) — rest: Tue(2), Thu(4), Fri(5), Sun(7)
            return dayNumber == 2 || dayNumber == 4 || dayNumber == 5 || dayNumber == 7;
        } else {
            // 2 days/week: Mon, Thu are workouts
            return dayNumber != 1 && dayNumber != 4;
        }
    }

    // Helper: Determine focus area based on day and target
    private String determineFocusArea(int dayNumber, int frequencyPerWeek, String targetMuscle) {
        if (targetMuscle != null && !targetMuscle.equalsIgnoreCase("Full Body")) {
            return targetMuscle;
        }

        // For full body plans, rotate focus areas
        if (frequencyPerWeek <= 3) {
            return "Full Body";
        }

        // For higher frequency, split by muscle groups
        return switch (dayNumber % 4) {
            case 1 -> "Upper Body Push";
            case 2 -> "Lower Body";
            case 3 -> "Upper Body Pull";
            case 0 -> "Core & Cardio";
            default -> "Full Body";
        };
    }

    // Helper: Get warm-up notes
    private String getWarmUpNotes(String focusArea) {
        return String.format("5-10 minutes: Light cardio + dynamic stretching focused on %s. " +
                "Include joint mobility and muscle activation exercises.", focusArea.toLowerCase());
    }

    // Helper: Get cool-down notes
    private String getCoolDownNotes() {
        return "5-10 minutes: Static stretching of worked muscles. " +
                "Focus on breathing and gradual heart rate reduction.";
    }

    // Helper: Calculate exercises per session
    private int calculateExercisesPerSession(String goalType, String difficulty) {
        String goalUpper = goalType.toUpperCase();
        
        if (goalUpper.contains("STRENGTH")) {
            return 4; // Fewer exercises, more focus on heavy compound movements
        } else if (goalUpper.contains("BODYBUILDING") || goalUpper.contains("MUSCLE") || goalUpper.contains("GAIN")) {
            return 6; // More volume for hypertrophy
        } else if (goalUpper.contains("SLIMFIT") || goalUpper.contains("ATHLETIC") || goalUpper.contains("FAT") || goalUpper.contains("LOSS") || goalUpper.contains("ENDURANCE")) {
            return 5; // Circuit/athletic style, moderate volume
        }
        
        // Default based on difficulty
        return switch (difficulty.toUpperCase()) {
            case "BEGINNER" -> 4;
            case "ADVANCED" -> 6;
            default -> 5;
        };
    }

    // Helper: Select exercises for a session
    private List<Exercise> selectExercisesForSession(List<Exercise> allExercises, int count, int dayNumber) {
        if (allExercises.isEmpty()) {
            return List.of();
        }

        List<Exercise> selected = new ArrayList<>();
        
        // Calculate offset based on day to get variety across days
        int offset = (dayNumber - 1) * count;
        
        for (int i = 0; i < count && (offset + i) < allExercises.size(); i++) {
            selected.add(allExercises.get((offset + i) % allExercises.size()));
        }

        // If we don't have enough exercises, repeat from the start
        while (selected.size() < count && !allExercises.isEmpty()) {
            selected.add(allExercises.get(selected.size() % allExercises.size()));
        }

        return selected;
    }

    // Helper: Create SessionExercise with sets, reps, rest based on goal
    private SessionExercise createSessionExercise(WorkoutSession session, Exercise exercise, 
                                                  int orderIndex, String goalType, String difficulty) {
        SessionExercise se = new SessionExercise();
        se.setWorkoutSession(session);
        se.setExercise(exercise);
        se.setOrderIndex(orderIndex);

        String goalUpper = goalType.toUpperCase();

        // Set parameters based on goal
        if (goalUpper.contains("STRENGTH")) {
            // Strength: Low reps, high weight, long rest
            se.setSets(5);
            se.setRepetitions(5);
            se.setRestTimeSeconds(180); // 3 minutes
            se.setNotes("Focus on heavy weight and proper form. Rest fully between sets.");
        } else if (goalUpper.contains("BODYBUILDING") || goalUpper.contains("MUSCLE") || goalUpper.contains("GAIN")) {
            // Hypertrophy: Moderate reps, moderate rest
            se.setSets(4);
            se.setRepetitions(10);
            se.setRestTimeSeconds(90); // 90 seconds
            se.setNotes("Focus on time under tension. Control the eccentric phase.");
        } else if (goalUpper.contains("SLIMFIT") || goalUpper.contains("FAT") || goalUpper.contains("LOSS")) {
            // Fat loss / Slimfit: Higher reps, shorter rest (circuit style)
            se.setSets(3);
            se.setRepetitions(15);
            se.setRestTimeSeconds(45); // 45 seconds
            se.setNotes("Keep intensity high. Minimize rest between exercises.");
        } else if (goalUpper.contains("ATHLETIC")) {
            // Athletic: Power & functional strength
            se.setSets(4);
            se.setRepetitions(8);
            se.setRestTimeSeconds(90); // 90 seconds
            se.setNotes("Focus on explosive power, speed, and functional movement control.");
        } else if (goalUpper.contains("ENDURANCE")) {
            // Endurance: High reps, light weight, short rest
            se.setSets(3);
            se.setRepetitions(20);
            se.setRestTimeSeconds(30); // 30 seconds
            se.setNotes("Focus on endurance and cardiovascular conditioning.");
        } else {
            // Default: Balanced approach
            se.setSets(3);
            se.setRepetitions(12);
            se.setRestTimeSeconds(60); // 60 seconds
            se.setNotes("Focus on proper form and controlled movements.");
        }

        // Adjust for difficulty level
        if (difficulty.equalsIgnoreCase("BEGINNER")) {
            se.setSets(Math.max(2, se.getSets() - 1));
            se.setRestTimeSeconds(se.getRestTimeSeconds() + 15);
        } else if (difficulty.equalsIgnoreCase("ADVANCED")) {
            se.setSets(se.getSets() + 1);
        }

        // Recommend weight based on user profile and exercise
        Float recommendedWeight = null;
        try {
            Long userId = session.getWorkoutPlan().getUser().getUserId();
            recommendedWeight = weightRecommendationService.recommendWeight(
                userId, 
                exercise.getExerciseId(), 
                se.getRepetitions(), 
                goalType
            );
        } catch (Exception e) {
            log.warn("Failed to recommend weight for exercise {}: {}", exercise.getExerciseId(), e.getMessage());
        }
        
        se.setWeightKg(recommendedWeight);
        se.setIsSuperset(false);

        return se;
    }
}
