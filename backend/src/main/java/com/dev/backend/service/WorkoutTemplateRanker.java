package com.dev.backend.service;

import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.WorkoutTemplate;

import java.util.List;

/**
 * Strategy interface for ranking workout templates based on user profile.
 * Implementations can be rule-based, AI-powered, or collaborative filtering.
 */
public interface WorkoutTemplateRanker {

    /**
     * Rank and return the top N templates for the given user profile.
     * @param profile the user's training profile
     * @param limit maximum number of templates to return
     * @return list of templates sorted by relevance score (highest first)
     */
    List<WorkoutTemplate> rankTemplatesForUser(UserProfile profile, int limit);

    /**
     * Return a human-readable explanation for why a template was recommended.
     * @param template the template
     * @param profile the user profile
     * @return explanation string
     */
    String explainRecommendation(WorkoutTemplate template, UserProfile profile);
}
