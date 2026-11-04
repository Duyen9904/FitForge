package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingProgressRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.UserProfileService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserProfileServiceImpl implements UserProfileService {

    private final UserRepository userRepository;
    private final OnboardingStepRepository stepRepository;
    private final UserOnboardingProgressRepository progressRepository;
    private final ObjectMapper objectMapper;

    @Override
    public UserProfile buildProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        // Index progress by stepKey for easier lookup
        List<OnboardingStep> steps = stepRepository.findByIsActiveTrueOrderByDisplayOrderAsc();
        Map<Long, OnboardingStep> stepById = steps.stream()
                .collect(Collectors.toMap(OnboardingStep::getStepId, s -> s));

        List<UserOnboardingProgress> progressList = progressRepository.findByUserUserId(userId);

        // Index progress by stepType (more robust than relying on step_key naming conventions)
        // This avoids mismatches like 'fitness_goal' (seed data) vs 'FITNESS_GOAL_*' (previous assumption).
        Map<OnboardingStepType, JsonNode> responsesByType = new EnumMap<>(OnboardingStepType.class);
        for (UserOnboardingProgress progress : progressList) {
            if (progress.getResponseData() == null) {
                continue;
            }
            OnboardingStep step = stepById.get(progress.getStep().getStepId());
            if (step == null || step.getStepType() == null) {
                continue;
            }
            responsesByType.put(step.getStepType(), parseJsonSafe(progress.getResponseData()));
        }

        // Derive primitive attributes from User and preferences
        Integer ageYears = null;
        if (user.getDateOfBirth() != null) {
            ageYears = Period.between(user.getDateOfBirth(), LocalDate.now()).getYears();
        }

        List<String> goalKeys = extractStringList(responsesByType, OnboardingStepType.FITNESS_GOAL, "selectedOptions");
        List<String> equipmentKeys = extractStringList(responsesByType, OnboardingStepType.EQUIPMENT, "selectedOptions");
        List<String> scheduleDays = extractStringList(responsesByType, OnboardingStepType.SCHEDULE, "days");
        List<String> healthLimitations = extractStringList(responsesByType, OnboardingStepType.HEALTH_LIMITATIONS, "selectedOptions");

        Integer preferredDuration = extractInteger(responsesByType, OnboardingStepType.SCHEDULE, "duration");
        String preferredTimeOfDay = extractString(responsesByType, OnboardingStepType.SCHEDULE, "timeOfDay");

        Boolean workoutRemindersEnabled = null;
        JsonNode notificationsNode = responsesByType.get(OnboardingStepType.NOTIFICATIONS);
        if (notificationsNode != null && notificationsNode.has("workoutReminders")) {
            workoutRemindersEnabled = notificationsNode.get("workoutReminders").asBoolean();
        }

        return UserProfile.builder()
                .userId(user.getUserId())
                .gender(user.getGender())
                .ageYears(ageYears)
                .heightCm(user.getHeightCm())
                .currentWeightKg(user.getCurrentWeightKg())
                .targetWeightKg(user.getTargetWeightKg())
                .fitnessLevel(user.getFitnessLevel())
                .primaryGoalName(user.getPrimaryGoal() != null ? user.getPrimaryGoal().getGoalName() : null)
                .goalKeys(goalKeys)
                .equipmentKeys(equipmentKeys)
                .scheduleDays(scheduleDays)
                .preferredSessionDuration(preferredDuration)
                .preferredTimeOfDay(preferredTimeOfDay)
                .healthLimitations(healthLimitations)
                .maintenanceCaloriesEstimate(null) // can be set by recommendation logic later
                .dailyCalorieTargetPreference(user.getUserPreference() != null ? user.getUserPreference().getDailyCalorieTarget() : null)
                .dailyProteinTargetGPreference(user.getUserPreference() != null ? user.getUserPreference().getDailyProteinTargetG() : null)
                .dailyCarbsTargetGPreference(user.getUserPreference() != null ? user.getUserPreference().getDailyCarbsTargetG() : null)
                .dailyFatsTargetGPreference(user.getUserPreference() != null ? user.getUserPreference().getDailyFatsTargetG() : null)
                .workoutRemindersEnabled(workoutRemindersEnabled != null ? workoutRemindersEnabled : (user.getUserPreference() != null && user.getUserPreference().getNotificationEnabled()))
                .build();
    }

    private JsonNode parseJsonSafe(String json) {
        try {
            return objectMapper.readTree(json);
        } catch (IOException e) {
            return objectMapper.createObjectNode();
        }
    }

    private List<String> extractStringList(Map<OnboardingStepType, JsonNode> responsesByType,
                                           OnboardingStepType stepType,
                                           String fieldName) {
        JsonNode root = responsesByType.get(stepType);
        if (root == null) {
            return new ArrayList<>();
        }
        JsonNode node = root.get(fieldName);
        List<String> values = new ArrayList<>();
        if (node != null && node.isArray()) {
            node.forEach(n -> values.add(n.asText()));
        }
        return values;
    }

    private Integer extractInteger(Map<OnboardingStepType, JsonNode> responsesByType,
                                   OnboardingStepType stepType,
                                   String fieldName) {
        JsonNode root = responsesByType.get(stepType);
        if (root == null) {
            return null;
        }
        JsonNode node = root.get(fieldName);
        return node != null && node.isNumber() ? node.intValue() : null;
    }

    private String extractString(Map<OnboardingStepType, JsonNode> responsesByType,
                                 OnboardingStepType stepType,
                                 String fieldName) {
        JsonNode root = responsesByType.get(stepType);
        if (root == null) {
            return null;
        }
        JsonNode node = root.get(fieldName);
        return node != null && !node.isNull() ? node.asText() : null;
    }
}
