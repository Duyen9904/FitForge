package com.dev.backend.service;

import com.dev.backend.model.dto.response.ExerciseRecommendationResponse;

import java.util.List;

public interface RecommendationService {

    /**
     * Get exercise recommendations based on user context (UC-12.3)
     * Analyzes:
     * - Current session's exercises
     * - Muscle groups already targeted
     * - User's fitness goal
     * - User's fitness level
     * - Available equipment
     * - Historical preferences
     */
    List<ExerciseRecommendationResponse> getExerciseRecommendations(Long userId, Long sessionId, int limit);
}
