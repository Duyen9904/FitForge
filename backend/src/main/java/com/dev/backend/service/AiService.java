package com.dev.backend.service;

import com.dev.backend.model.dto.ai.AiPlanAdjustmentContext;
import com.dev.backend.model.dto.ai.AiPlanGenerationContext;
import com.dev.backend.model.dto.ai.AiWorkoutPlanResult;

/**
 * Abstraction for AI-powered workout plan generation and adjustment.
 * Implementations can use any LLM provider (OpenRouter, OpenAI, etc.).
 */
public interface AiService {

    /**
     * Generate a workout plan with week 1 sessions based on user context.
     *
     * @param context all inputs the AI needs (user profile, exercises, preferences)
     * @return structured plan result with sessions and exercises
     */
    AiWorkoutPlanResult generateWorkoutPlan(AiPlanGenerationContext context);

    /**
     * Adjust a workout plan based on behavior data (adherence, RPE, pain flags).
     *
     * @param context current plan info plus behavioral metrics
     * @return adjusted plan result
     */
    AiWorkoutPlanResult adjustWorkoutPlan(AiPlanAdjustmentContext context);
}
