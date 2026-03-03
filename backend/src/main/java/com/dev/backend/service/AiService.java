package com.dev.backend.service;

import com.dev.backend.model.dto.ai.AiPlanAdjustmentContext;
import com.dev.backend.model.dto.ai.AiPlanGenerationContext;
import com.dev.backend.model.dto.ai.AiStructureResult;
import com.dev.backend.model.dto.ai.AiWorkoutPlanResult;

/**
 * Abstraction for AI-powered workout plan generation and adjustment.
 * Implementations can use any LLM provider (OpenRouter, OpenAI, etc.).
 */
public interface AiService {

    /**
     * Generate a workout plan structure with exercise slots (not concrete exercises).
     * The AI outputs muscle groups + movement patterns; the backend ExerciseSelector
     * fills in real exercises from the database.
     *
     * @param context all inputs the AI needs (user profile, preferences)
     * @return structured plan with exercise slots (muscle group + pattern + sets/reps)
     */
    AiStructureResult generateWorkoutStructure(AiPlanGenerationContext context);

    /**
     * Adjust a workout plan based on behavior data (adherence, RPE, pain flags).
     *
     * @param context current plan info plus behavioral metrics
     * @return adjusted plan result
     */
    AiWorkoutPlanResult adjustWorkoutPlan(AiPlanAdjustmentContext context);
}
