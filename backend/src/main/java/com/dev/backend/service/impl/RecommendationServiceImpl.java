package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.response.ExerciseRecommendationResponse;
import com.dev.backend.model.entity.*;
import com.dev.backend.repository.*;
import com.dev.backend.service.RecommendationService;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class RecommendationServiceImpl implements RecommendationService {

    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;
    private final WorkoutSessionRepository workoutSessionRepository;
    private final ExerciseLogRepository exerciseLogRepository;

    public RecommendationServiceImpl(
            UserRepository userRepository,
            ExerciseRepository exerciseRepository,
            WorkoutSessionRepository workoutSessionRepository,
            ExerciseLogRepository exerciseLogRepository) {
        this.userRepository = userRepository;
        this.exerciseRepository = exerciseRepository;
        this.workoutSessionRepository = workoutSessionRepository;
        this.exerciseLogRepository = exerciseLogRepository;
    }

    @Override
    public List<ExerciseRecommendationResponse> getExerciseRecommendations(Long userId, Long sessionId, int limit) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Get user's fitness goal for recommendations
        Goal primaryGoal = user.getPrimaryGoal();
        String fitnessLevel = user.getFitnessLevel();

        // Get muscle groups already targeted in session (if provided)
        Set<Long> targetedMuscleGroupIds = new HashSet<>();
        if (sessionId != null) {
            workoutSessionRepository.findById(sessionId).ifPresent(session -> {
                session.getSessionExercises().forEach(se -> {
                    se.getExercise().getExerciseMuscleGroups().forEach(emg -> {
                        targetedMuscleGroupIds.add(emg.getMuscleGroup().getMuscleGroupId());
                    });
                });
            });
        }

        // Get exercises and score them
        List<Exercise> allExercises = exerciseRepository.findAll();
        List<ExerciseRecommendationResponse> recommendations = new ArrayList<>();

        for (Exercise exercise : allExercises) {
            int score = calculateRelevanceScore(exercise, primaryGoal, fitnessLevel,
                    targetedMuscleGroupIds);
            
            if (score > 0) {
                String rationale = generateRationale(exercise, primaryGoal, targetedMuscleGroupIds);
                String primaryMuscle = exercise.getExerciseMuscleGroups().stream()
                        .filter(emg -> Boolean.TRUE.equals(emg.getIsPrimary()))
                        .findFirst()
                        .map(emg -> emg.getMuscleGroup().getGroupName())
                        .orElse(null);

                recommendations.add(ExerciseRecommendationResponse.builder()
                        .exerciseId(exercise.getExerciseId())
                        .exerciseName(exercise.getExerciseName())
                        .description(exercise.getDescription())
                        .difficultyLevel(exercise.getDifficultyLevel())
                        .exerciseType(exercise.getExerciseType())
                        .primaryMuscleGroup(primaryMuscle)
                        .rationale(rationale)
                        .relevanceScore(score)
                        .build());
            }
        }

        // Sort by relevance score and limit
        return recommendations.stream()
                .sorted(Comparator.comparingInt(ExerciseRecommendationResponse::getRelevanceScore).reversed())
                .limit(limit)
                .collect(Collectors.toList());
    }

    private int calculateRelevanceScore(Exercise exercise, Goal goal, String fitnessLevel,
                                         Set<Long> targetedMuscleGroupIds) {
        int score = 50; // Base score

        // Bonus for matching fitness level
        if (fitnessLevel != null && fitnessLevel.equalsIgnoreCase(exercise.getDifficultyLevel())) {
            score += 15;
        }

        // Bonus for complementary muscle groups (not already targeted)
        boolean targetsNewMuscle = exercise.getExerciseMuscleGroups().stream()
                .anyMatch(emg -> !targetedMuscleGroupIds.contains(emg.getMuscleGroup().getMuscleGroupId()));
        if (targetsNewMuscle && !targetedMuscleGroupIds.isEmpty()) {
            score += 25;
        }

        // Adjust for goal alignment
        if (goal != null) {
            score += getGoalAlignmentBonus(exercise, goal);
        }

        return Math.min(100, score);
    }

    private int getGoalAlignmentBonus(Exercise exercise, Goal goal) {
        String goalName = goal.getGoalName().toLowerCase();
        String exerciseType = exercise.getExerciseType() != null ? exercise.getExerciseType().toLowerCase() : "";

        if (goalName.contains("strength") && exerciseType.contains("compound")) {
            return 15;
        } else if (goalName.contains("muscle") && (exerciseType.contains("compound") || exerciseType.contains("isolation"))) {
            return 10;
        } else if (goalName.contains("endurance") && exerciseType.contains("cardio")) {
            return 15;
        } else if (goalName.contains("fat loss") && exerciseType.contains("cardio")) {
            return 10;
        }
        return 0;
    }

    private String generateRationale(Exercise exercise, Goal goal,
                                      Set<Long> targetedMuscleGroupIds) {
        List<String> reasons = new ArrayList<>();

        // Check for complementary muscles
        boolean targetsNewMuscle = exercise.getExerciseMuscleGroups().stream()
                .anyMatch(emg -> !targetedMuscleGroupIds.contains(emg.getMuscleGroup().getMuscleGroupId()));
        
        if (targetsNewMuscle && !targetedMuscleGroupIds.isEmpty()) {
            String newMuscle = exercise.getExerciseMuscleGroups().stream()
                    .filter(emg -> !targetedMuscleGroupIds.contains(emg.getMuscleGroup().getMuscleGroupId()))
                    .findFirst()
                    .map(emg -> emg.getMuscleGroup().getGroupName())
                    .orElse("new muscle group");
            reasons.add("Targets " + newMuscle + " for balanced development");
        }

        if (goal != null) {
            reasons.add("Aligns with your " + goal.getGoalName() + " goal");
        }

        if (reasons.isEmpty()) {
            reasons.add("Recommended based on your fitness profile");
        }

        return String.join(". ", reasons);
    }
}
