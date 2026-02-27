package com.dev.backend.service.impl;

import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.WorkoutTemplate;
import com.dev.backend.repository.WorkoutTemplateRepository;
import com.dev.backend.service.WorkoutTemplateRanker;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Rule-based implementation of WorkoutTemplateRanker.
 * Scores templates by matching goal, experience, equipment, days/week, and constraints.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RuleBasedWorkoutTemplateRanker implements WorkoutTemplateRanker {

    private final WorkoutTemplateRepository templateRepository;

    @Override
    public List<WorkoutTemplate> rankTemplatesForUser(UserProfile profile, int limit) {
        List<WorkoutTemplate> allTemplates = templateRepository.findByIsActiveTrueOrderByNameAsc();

        List<ScoredTemplate> scoredTemplates = allTemplates.stream()
                .map(template -> new ScoredTemplate(template, scoreTemplate(template, profile)))
                .filter(st -> st.score > 0)
                .sorted(Comparator.comparingInt(st -> -st.score))
                .limit(limit)
                .collect(Collectors.toList());

        return scoredTemplates.stream()
                .map(st -> st.template)
                .collect(Collectors.toList());
    }

    @Override
    public String explainRecommendation(WorkoutTemplate template, UserProfile profile) {
        List<String> reasons = new ArrayList<>();

        // Goal match
        if (profile.getPrimaryGoalName() != null &&
                template.getGoalType() != null &&
                template.getGoalType().toUpperCase().contains(profile.getPrimaryGoalName().toUpperCase().replace(" ", "_"))) {
            reasons.add("Matches your " + profile.getPrimaryGoalName() + " goal");
        }

        // Experience level match
        if (profile.getFitnessLevel() != null &&
                template.getExperienceLevel() != null &&
                template.getExperienceLevel().equalsIgnoreCase(profile.getFitnessLevel())) {
            reasons.add("Designed for " + profile.getFitnessLevel().toLowerCase() + " level");
        }

        // Days per week match
        if (profile.getScheduleDays() != null && !profile.getScheduleDays().isEmpty() &&
                template.getDaysPerWeek() != null &&
                template.getDaysPerWeek() == profile.getScheduleDays().size()) {
            reasons.add("Fits your " + template.getDaysPerWeek() + " days/week schedule");
        }

        // Equipment compatibility
        if (profile.getEquipmentKeys() != null && !profile.getEquipmentKeys().isEmpty() &&
                template.getEquipmentTags() != null && !template.getEquipmentTags().isEmpty()) {
            Set<String> userEquipment = profile.getEquipmentKeys().stream()
                    .map(String::toUpperCase)
                    .collect(Collectors.toSet());
            Set<String> requiredEquipment = Arrays.stream(template.getEquipmentTags().split(","))
                    .map(String::trim)
                    .map(String::toUpperCase)
                    .collect(Collectors.toSet());

            if (userEquipment.containsAll(requiredEquipment)) {
                reasons.add("Compatible with your available equipment");
            }
        }

        if (reasons.isEmpty()) {
            reasons.add("Recommended based on your fitness profile");
        }

        return String.join(". ", reasons);
    }

    private int scoreTemplate(WorkoutTemplate template, UserProfile profile) {
        int score = 50; // Base score

        // Goal match: +30 for exact, +15 for related
        if (profile.getPrimaryGoalName() != null && template.getGoalType() != null) {
            String normalizedGoal = profile.getPrimaryGoalName().toUpperCase().replace(" ", "_");
            String templateGoal = template.getGoalType().toUpperCase();

            if (templateGoal.contains(normalizedGoal) || normalizedGoal.contains(templateGoal)) {
                score += 30;
            } else if (areRelatedGoals(normalizedGoal, templateGoal)) {
                score += 15;
            }
        }

        // Experience level match: +20 for exact match
        if (profile.getFitnessLevel() != null &&
                template.getExperienceLevel() != null &&
                template.getExperienceLevel().equalsIgnoreCase(profile.getFitnessLevel())) {
            score += 20;
        }

        // Days per week compatibility: +15 for exact match, +5 for ±1 day
        if (profile.getScheduleDays() != null && !profile.getScheduleDays().isEmpty() && template.getDaysPerWeek() != null) {
            int userDays = profile.getScheduleDays().size();
            int templateDays = template.getDaysPerWeek();

            if (userDays == templateDays) {
                score += 15;
            } else if (Math.abs(userDays - templateDays) == 1) {
                score += 5;
            }
        }

        // Equipment compatibility: must be subset of user's equipment
        if (template.getEquipmentTags() != null && !template.getEquipmentTags().isEmpty()) {
            if (profile.getEquipmentKeys() == null || profile.getEquipmentKeys().isEmpty()) {
                score -= 50; // User has no equipment, template requires equipment
            } else {
                Set<String> userEquipment = profile.getEquipmentKeys().stream()
                        .map(String::toUpperCase)
                        .collect(Collectors.toSet());
                Set<String> requiredEquipment = Arrays.stream(template.getEquipmentTags().split(","))
                        .map(String::trim)
                        .map(String::toUpperCase)
                        .collect(Collectors.toSet());

                if (userEquipment.containsAll(requiredEquipment)) {
                    score += 10;
                } else {
                    score -= 30; // Missing required equipment
                }
            }
        }

        // Contraindications: reject if template violates user's health limitations
        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty() &&
                template.getContraindications() != null && !template.getContraindications().isEmpty()) {

            Set<String> userLimitations = profile.getHealthLimitations().stream()
                    .map(String::toUpperCase)
                    .collect(Collectors.toSet());
            Set<String> templateContraindications = Arrays.stream(template.getContraindications().split(","))
                    .map(String::trim)
                    .map(String::toUpperCase)
                    .collect(Collectors.toSet());

            // If any user limitation matches a contraindication, this template is unsafe
            for (String limitation : userLimitations) {
                if (templateContraindications.contains(limitation)) {
                    return 0; // Disqualify this template
                }
            }
        }

        return Math.min(100, Math.max(0, score));
    }

    private boolean areRelatedGoals(String goal1, String goal2) {
        Map<String, Set<String>> relatedGoals = Map.of(
                "MUSCLE_GAIN", Set.of("STRENGTH", "BUILD_MUSCLE"),
                "STRENGTH", Set.of("MUSCLE_GAIN", "BUILD_MUSCLE"),
                "FAT_LOSS", Set.of("WEIGHT_LOSS", "LOSE_FAT", "ENDURANCE"),
                "ENDURANCE", Set.of("FAT_LOSS", "CARDIO")
        );

        return relatedGoals.getOrDefault(goal1, Collections.emptySet()).contains(goal2) ||
               relatedGoals.getOrDefault(goal2, Collections.emptySet()).contains(goal1);
    }

    private static class ScoredTemplate {
        final WorkoutTemplate template;
        final int score;

        ScoredTemplate(WorkoutTemplate template, int score) {
            this.template = template;
            this.score = score;
        }
    }
}
