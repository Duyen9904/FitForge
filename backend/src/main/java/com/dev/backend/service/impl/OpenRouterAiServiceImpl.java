package com.dev.backend.service.impl;

import com.dev.backend.config.CacheNames;
import com.dev.backend.model.dto.ai.*;
import com.dev.backend.service.AiService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.chat.completions.ChatCompletion;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.*;
import java.util.concurrent.CompletableFuture;

/**
 * AI service implementation using OpenRouter (OpenAI-compatible API).
 * <p>
 * Uses single-shot prompting for both plan generation and adjustment:
 * - Plan generation: AI outputs workout STRUCTURE (exercise slots with muscle groups + patterns).
 *   The backend ExerciseSelector fills in real exercises from the database.
 * - Plan adjustment: AI outputs adjusted plan based on behavior metrics.
 */
@Service
@Slf4j
public class OpenRouterAiServiceImpl implements AiService {

    @Value("${openrouter.api-key:}")
    private String apiKey;

    @Value("${openrouter.base-url:https://openrouter.ai/api/v1}")
    private String baseUrl;

    @Value("${openrouter.model:openai/gpt-4o-mini}")
    private String model;

    @Value("${openrouter.max-tokens:4000}")
    private int maxTokens;

    @Value("${openrouter.temperature:0.7}")
    private double temperature;

    @Value("${openrouter.timeout:120}")
    private int timeoutSeconds;

    private final ObjectMapper objectMapper;
    private OpenAIClient client;

    public OpenRouterAiServiceImpl(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    void init() {
        if (apiKey != null && !apiKey.isBlank()) {
            this.client = OpenAIOkHttpClient.builder()
                    .apiKey(apiKey)
                    .baseUrl(baseUrl)
                    .timeout(Duration.ofSeconds(timeoutSeconds))
                    .build();
            log.info("OpenRouter AI service initialized with model: {}", model);
        } else {
            log.warn("OpenRouter API key not configured. AI plan generation will not be available.");
        }
    }

    // ==================== STRUCTURE-ONLY PLAN GENERATION ====================

    @Override
    @Cacheable(value = CacheNames.AI_PLANS,
               key = "'workout:' + #context.profile.userId + ':' + #context.goalName + ':' + #context.frequencyPerWeek",
               unless = "#result == null")
    public AiStructureResult generateWorkoutStructure(AiPlanGenerationContext context) {
        if (client == null) {
            throw new IllegalStateException("OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.");
        }

        log.info("[AI-STRUCTURE] Starting structure-only plan generation for user {} | Goal: {} | Frequency: {}/week",
                context.getProfile().getUserId(),
                context.getGoalName(),
                context.getFrequencyPerWeek());

        String systemPrompt = buildStructureSystemPrompt();
        String userPrompt = buildStructureUserPrompt(context);

        long totalStart = System.currentTimeMillis();
        String jsonResponse = callAiSingleShot(systemPrompt, userPrompt, "STRUCTURE_GENERATION");
        AiStructureResult result = parseStructureResponse(jsonResponse);
        long totalMs = System.currentTimeMillis() - totalStart;

        int sessionCount = result.getSessions() != null ? result.getSessions().size() : 0;
        log.info("[AI-STRUCTURE] Completed in {} ms | Plan: '{}' | Sessions: {}",
                totalMs, result.getPlanName(), sessionCount);

        return result;
    }

    private AiStructureResult parseStructureResponse(String jsonContent) {
        try {
            String cleaned = stripMarkdownFences(jsonContent);
            return objectMapper.readValue(cleaned, AiStructureResult.class);
        } catch (Exception e) {
            log.error("Failed to parse AI structure response as JSON: {}", jsonContent, e);
            throw new RuntimeException("Failed to parse AI-generated workout structure. The AI returned invalid JSON.", e);
        }
    }

    // ==================== PLAN ADJUSTMENT ====================

    @Override
    @Cacheable(value = CacheNames.AI_PLANS,
               key = "'adjust:' + #context.profile.userId + ':' + #context.currentPlanName",
               unless = "#result == null")
    public AiWorkoutPlanResult adjustWorkoutPlan(AiPlanAdjustmentContext context) {
        if (client == null) {
            throw new IllegalStateException("OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.");
        }

        log.info("[AI-ADJUST] Starting plan adjustment for user {} | Plan: '{}' | Adherence: {} | Avg RPE: {} | Equipment: {}",
                context.getProfile().getUserId(),
                context.getCurrentPlanName(),
                context.getWorkoutAdherence() != null ? String.format("%.0f%%", context.getWorkoutAdherence() * 100) : "N/A",
                context.getAvgRPE() != null ? String.format("%.1f", context.getAvgRPE()) : "N/A",
                context.getAvailableEquipment() != null ? context.getAvailableEquipment().size() + " items" : "none");

        String systemPrompt = buildAdjustmentSystemPrompt();
        String userPrompt = buildAdjustmentUserPrompt(context);

        long totalStart = System.currentTimeMillis();
        String jsonResponse = callAiSingleShot(systemPrompt, userPrompt, "PLAN_ADJUSTMENT");
        AiWorkoutPlanResult result = parseAdjustmentResponse(jsonResponse);
        long totalMs = System.currentTimeMillis() - totalStart;

        int sessionCount = result.getSessions() != null ? result.getSessions().size() : 0;
        log.info("[AI-ADJUST] Completed in {} ms | Plan: '{}' | Sessions generated: {}",
                totalMs, result.getPlanName(), sessionCount);
        return result;
    }

    private AiWorkoutPlanResult parseAdjustmentResponse(String jsonContent) {
        try {
            String cleaned = stripMarkdownFences(jsonContent);
            return objectMapper.readValue(cleaned, AiWorkoutPlanResult.class);
        } catch (Exception e) {
            log.error("Failed to parse AI adjustment response as JSON: {}", jsonContent, e);
            throw new RuntimeException("Failed to parse AI-generated workout plan. The AI returned invalid JSON.", e);
        }
    }

    // ==================== API CALL ====================

    /**
     * Call AI with a simple system + user prompt (single-shot, no tools).
     *
     * @param flowName identifies the data flow, e.g. "STRUCTURE_GENERATION" or "PLAN_ADJUSTMENT"
     */
    private String callAiSingleShot(String systemPrompt, String userPrompt, String flowName) {
        log.info("========== OPENROUTER REQUEST [{}] ==========", flowName);
        log.info("[{}] Model: {} | MaxTokens: {} | Temperature: {}", flowName, model, maxTokens, temperature);
        log.info("[{}] System prompt ({} chars):\n{}", flowName, systemPrompt.length(), systemPrompt);
        log.info("[{}] User prompt ({} chars):\n{}", flowName, userPrompt.length(), userPrompt);

        ChatCompletionCreateParams params = ChatCompletionCreateParams.builder()
                .model(model)
                .maxTokens(maxTokens)
                .temperature(temperature)
                .addSystemMessage(systemPrompt)
                .addUserMessage(userPrompt)
                .build();

        long startTime = System.currentTimeMillis();
        ChatCompletion completion = client.chat().completions().create(params);
        long latencyMs = System.currentTimeMillis() - startTime;

        log.info("========== OPENROUTER RESPONSE [{}] ==========", flowName);
        log.info("[{}] Latency: {} ms ({} seconds)", flowName, latencyMs, latencyMs / 1000.0);
        log.info("[{}] Response ID: {}", flowName, completion.id());
        log.info("[{}] Model used: {}", flowName, completion.model());

        if (completion.usage().isPresent()) {
            var usage = completion.usage().get();
            log.info("[{}] Token usage - Prompt: {} | Completion: {} | Total: {}",
                    flowName, usage.promptTokens(), usage.completionTokens(), usage.totalTokens());
        } else {
            log.warn("[{}] No token usage info returned by OpenRouter", flowName);
        }

        if (!completion.choices().isEmpty()) {
            var firstChoice = completion.choices().get(0);
            log.info("[{}] Finish reason: {}", flowName, firstChoice.finishReason());
        }

        String content = completion.choices().stream()
                .findFirst()
                .flatMap(choice -> choice.message().content())
                .orElseThrow(() -> new RuntimeException("AI returned empty response"));

        log.info("[{}] Response content length: {} chars", flowName, content.length());
        log.info("[{}] Full AI response:\n{}", flowName, content);
        log.info("==========================================");
        return content;
    }

    // ==================== UTILITY ====================

    /**
     * Strip markdown code fences (```json ... ```) from AI responses.
     */
    private String stripMarkdownFences(String content) {
        String cleaned = content.trim();
        if (cleaned.startsWith("```json")) {
            cleaned = cleaned.substring(7);
        } else if (cleaned.startsWith("```")) {
            cleaned = cleaned.substring(3);
        }
        if (cleaned.endsWith("```")) {
            cleaned = cleaned.substring(0, cleaned.length() - 3);
        }
        return cleaned.trim();
    }

    // ==================== PROMPTS ====================

    private String buildStructureSystemPrompt() {
        return """
                You are a certified personal trainer. Design workout plan STRUCTURES only.

                OUTPUT RULES:
                - Respond with valid JSON ONLY. No markdown, no explanation.
                - Use the exact JSON schema below.

                EXERCISE SLOTS:
                - Do NOT specify exercise names. Specify muscle groups and movement patterns.
                - muscleGroup values: CHEST | BACK | SHOULDERS | ARMS | LEGS | CORE | GLUTES
                - movementPattern values: compound | isolation

                PLAN STRUCTURE:
                - Exactly 7 sessions (dayNumber 1–7)
                - Workout days: 4–6 exerciseSlots each
                - Rest days: isRestDay=true, exerciseSlots=[]
                - Distribute rest days evenly

                DIFFICULTY GUIDELINES:
                - BEGINNER: prefer compound, 3 sets, 10–12 reps, 60–90s rest
                - INTERMEDIATE: mix compound+isolation, 3–4 sets, 8–12 reps
                - ADVANCED: varied patterns, 4–5 sets, 6–15 reps

                SAFETY:
                - Back problems → avoid BACK compound, use isolation only
                - Knee problems → avoid LEGS compound, use isolation only
                - Shoulder problems → avoid SHOULDERS compound

                JSON SCHEMA:
                {
                  "planName": "<string>",
                  "description": "<string>",
                  "recommendationReason": "<string>",
                  "sessions": [{
                    "dayNumber": <1-7>,
                    "sessionName": "<string>",
                    "focusArea": "<string>",
                    "estimatedDuration": <minutes>,
                    "isRestDay": <boolean>,
                    "warmUpNotes": "<string>",
                    "coolDownNotes": "<string>",
                    "exerciseSlots": [{
                      "muscleGroup": "<CHEST|BACK|SHOULDERS|ARMS|LEGS|CORE|GLUTES>",
                      "movementPattern": "<compound|isolation>",
                      "sets": <integer>,
                      "repetitions": "<string>",
                      "restTimeSeconds": <integer>,
                      "orderIndex": <integer>,
                      "notes": "<string or null>"
                    }]
                  }]
                }
                """;
    }

    private String buildStructureUserPrompt(AiPlanGenerationContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        sb.append("PROFILE: ");
        List<String> profileParts = new ArrayList<>();
        if (profile.getGender() != null) profileParts.add(profile.getGender());
        if (profile.getAgeYears() != null) profileParts.add("age " + profile.getAgeYears());
        if (profile.getFitnessLevel() != null) profileParts.add(profile.getFitnessLevel());
        if (profile.getCurrentWeightKg() != null) profileParts.add(profile.getCurrentWeightKg() + "kg");
        sb.append(String.join(", ", profileParts)).append("\n");

        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty()) {
            sb.append("HEALTH LIMITS: ").append(String.join(", ", profile.getHealthLimitations())).append("\n");
        }

        sb.append("GOAL: ").append(context.getGoalName()).append("\n");
        sb.append("FREQUENCY: ").append(context.getFrequencyPerWeek()).append(" days/week\n");
        sb.append("DIFFICULTY: ").append(context.getDifficultyLevel()).append("\n");

        if (context.getTargetMuscleGroups() != null && !context.getTargetMuscleGroups().isEmpty()) {
            sb.append("PRIORITY MUSCLES: ").append(String.join(", ", context.getTargetMuscleGroups()));
            sb.append(" (emphasize but keep balanced)\n");
        }

        if (context.getAvailableEquipment() != null && !context.getAvailableEquipment().isEmpty()) {
            sb.append("EQUIPMENT: ").append(String.join(", ", context.getAvailableEquipment())).append("\n");
        }

        if (context.getWeekNumber() != null && context.getWeekNumber() > 1) {
            sb.append("WEEK: ").append(context.getWeekNumber()).append(" of ").append(context.getDurationWeeks()).append("\n");
        }

        if (context.getAdditionalInformation() != null && !context.getAdditionalInformation().isBlank()) {
            sb.append("NOTES: ").append(context.getAdditionalInformation()).append("\n");
        }

        sb.append("\nGenerate the 7-day plan structure JSON.");
        return sb.toString();
    }

    private String buildAdjustmentSystemPrompt() {
        return """
                You are a certified personal trainer specializing in adaptive training. \
                Analyze workout behavior data and adjust plans to optimize progress.

                ADJUSTMENT FRAMEWORK:
                - Adherence < 50%  → Reduce frequency by 1 day, simplify exercises
                - Adherence 50–80% → Maintain frequency, reduce volume if RPE high
                - Adherence > 80% + RPE < 5 → Increase intensity or add 1 exercise
                - Adherence > 80% + RPE 5–7 → Maintain current level
                - Adherence > 80% + RPE > 8 → Reduce volume, add active recovery
                - Pain flags > 0 → Swap affected exercises with safe alternatives
                - Completion < 60% → Reduce to 3–4 exercises per session

                RULES:
                - Respond with valid JSON ONLY. No markdown.
                - Exactly 7 sessions (dayNumber 1–7)
                - Respect health limitations
                - Explain reasoning in "recommendationReason"

                JSON SCHEMA:
                {
                  "planName": "<string>",
                  "description": "<string>",
                  "recommendationReason": "<string>",
                  "sessions": [{
                    "dayNumber": <1-7>,
                    "sessionName": "<string>",
                    "focusArea": "<string>",
                    "estimatedDuration": <minutes>,
                    "isRestDay": <boolean>,
                    "warmUpNotes": "<string>",
                    "coolDownNotes": "<string>",
                    "exercises": [{
                      "exerciseName": "<string>",
                      "sets": <integer>,
                      "repetitions": "<string>",
                      "weightKg": <number or null>,
                      "restTimeSeconds": <integer>,
                      "orderIndex": <integer>,
                      "notes": "<string>"
                    }]
                  }]
                }
                """;
    }

    private String buildAdjustmentUserPrompt(AiPlanAdjustmentContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        sb.append("PROFILE: ");
        List<String> parts = new ArrayList<>();
        if (profile.getGender() != null) parts.add(profile.getGender());
        if (profile.getAgeYears() != null) parts.add("age " + profile.getAgeYears());
        if (profile.getFitnessLevel() != null) parts.add(profile.getFitnessLevel());
        sb.append(String.join(", ", parts)).append("\n");

        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty()) {
            sb.append("HEALTH LIMITS: ").append(String.join(", ", profile.getHealthLimitations())).append("\n");
        }

        sb.append("EQUIPMENT: ");
        if (context.getAvailableEquipment() != null && !context.getAvailableEquipment().isEmpty()) {
            sb.append(String.join(", ", context.getAvailableEquipment()));
        } else {
            sb.append("Bodyweight only");
        }
        sb.append("\n");

        sb.append("CURRENT PLAN: ").append(context.getCurrentPlanName()).append("\n");
        sb.append("FREQUENCY: ").append(context.getFrequencyPerWeek()).append(" days/week\n");
        sb.append("DIFFICULTY: ").append(context.getDifficultyLevel()).append("\n");
        if (context.getGoalName() != null) sb.append("GOAL: ").append(context.getGoalName()).append("\n");
        if (context.getCurrentPlanSummary() != null) {
            sb.append("SESSIONS:\n").append(context.getCurrentPlanSummary()).append("\n");
        }

        sb.append("\nMETRICS (last 2 weeks):\n");
        if (context.getWorkoutAdherence() != null) {
            sb.append("- Adherence: ").append(String.format("%.0f%%", context.getWorkoutAdherence() * 100)).append("\n");
        }
        if (context.getAvgCompletionRate() != null) {
            sb.append("- Completion: ").append(String.format("%.0f%%", context.getAvgCompletionRate() * 100)).append("\n");
        }
        if (context.getAvgRPE() != null) {
            sb.append("- Avg RPE: ").append(String.format("%.1f", context.getAvgRPE())).append("/10\n");
        }
        if (context.getPainFlagCount() != null && context.getPainFlagCount() > 0) {
            sb.append("- Pain flags: ").append(context.getPainFlagCount()).append("\n");
        }

        sb.append("\nGenerate the adjusted plan JSON.");
        return sb.toString();
    }

    // ==================== NUTRITION PLAN GENERATION ====================

    @Override
    @Cacheable(value = CacheNames.AI_PLANS,
               key = "'nutrition:' + #context.profile.userId + ':' + #context.goalName",
               unless = "#result == null")
    public AiNutritionPlanResult generateNutritionPlan(AiNutritionPlanContext context) {
        if (client == null) {
            throw new IllegalStateException("OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.");
        }

        log.info("[AI-NUTRITION] Starting nutrition plan generation for user {} | Goal: {}",
                context.getProfile().getUserId(),
                context.getGoalName());

        String systemPrompt = buildNutritionSystemPrompt();
        String userPrompt = buildNutritionUserPrompt(context);

        long totalStart = System.currentTimeMillis();
        String jsonResponse = callAiSingleShot(systemPrompt, userPrompt, "NUTRITION_PLAN_GENERATION");
        AiNutritionPlanResult result = parseNutritionPlanResponse(jsonResponse);
        long totalMs = System.currentTimeMillis() - totalStart;

        int mealCount = result.getMeals() != null ? result.getMeals().size() : 0;
        log.info("[AI-NUTRITION] Completed in {} ms | Plan: '{}' | Calories: {} | Meals: {}",
                totalMs, result.getPlanName(), result.getDailyCalorieTarget(), mealCount);

        return result;
    }

    @Override
    @Cacheable(value = CacheNames.AI_PLANS,
               key = "'nutrition-adjust:' + #context.profile.userId + ':' + #context.currentPlanName",
               unless = "#result == null")
    public AiNutritionPlanResult adjustNutritionPlan(AiNutritionPlanContext context) {
        if (client == null) {
            throw new IllegalStateException("OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.");
        }

        log.info("[AI-NUTRITION-ADJUST] Starting nutrition plan adjustment for user {} | Current plan: '{}' | Adherence: {}",
                context.getProfile().getUserId(),
                context.getCurrentPlanName(),
                context.getNutritionAdherence() != null ? String.format("%.0f%%", context.getNutritionAdherence() * 100) : "N/A");

        String systemPrompt = buildNutritionAdjustmentSystemPrompt();
        String userPrompt = buildNutritionAdjustmentUserPrompt(context);

        long totalStart = System.currentTimeMillis();
        String jsonResponse = callAiSingleShot(systemPrompt, userPrompt, "NUTRITION_PLAN_ADJUSTMENT");
        AiNutritionPlanResult result = parseNutritionPlanResponse(jsonResponse);
        long totalMs = System.currentTimeMillis() - totalStart;

        log.info("[AI-NUTRITION-ADJUST] Completed in {} ms | Plan: '{}' | New calories: {}",
                totalMs, result.getPlanName(), result.getDailyCalorieTarget());

        return result;
    }

    private AiNutritionPlanResult parseNutritionPlanResponse(String jsonContent) {
        try {
            String cleaned = stripMarkdownFences(jsonContent);
            return objectMapper.readValue(cleaned, AiNutritionPlanResult.class);
        } catch (Exception e) {
            log.error("Failed to parse AI nutrition plan response as JSON: {}", jsonContent, e);
            throw new RuntimeException("Failed to parse AI-generated nutrition plan. The AI returned invalid JSON.", e);
        }
    }

    // ==================== NUTRITION PROMPTS ====================

    private String buildNutritionSystemPrompt() {
        return """
                You are a certified nutritionist and dietitian. Design personalized nutrition plans.

                OUTPUT RULES:
                - Respond with valid JSON ONLY. No markdown, no explanation.
                - Use the exact JSON schema below.

                MEAL PLANNING RULES:
                - Generate exactly 4 meals: BREAKFAST, LUNCH, DINNER, SNACK
                - Total meal calories must sum to dailyCalorieTarget (±5% tolerance)
                - Each meal must have realistic macro breakdowns (protein, carbs, fats in grams)
                - Provide practical, common food-based meals (not supplements)
                - Include brief recipe instructions for each meal

                CALORIE DISTRIBUTION:
                - BREAKFAST: ~25% of daily calories
                - LUNCH: ~35% of daily calories
                - DINNER: ~30% of daily calories
                - SNACK: ~10% of daily calories

                MACRO GUIDELINES BY GOAL:
                - Fat loss: protein 30-35%, carbs 25-35%, fats 30-35%
                - Muscle gain: protein 30-35%, carbs 40-45%, fats 20-25%
                - Maintenance/General fitness: protein 25-30%, carbs 40-45%, fats 25-30%
                - Endurance: protein 20-25%, carbs 50-55%, fats 20-25%

                SAFETY:
                - Respect dietary restrictions and allergies
                - Do not suggest raw meats, unpasteurized items, or known allergens
                - Minimum 1200 calories for any plan

                JSON SCHEMA:
                {
                  "planName": "<descriptive plan name>",
                  "description": "<1-2 sentence plan overview>",
                  "recommendationReason": "<why this plan suits the user>",
                  "dailyCalorieTarget": <integer>,
                  "proteinPercentage": <float>,
                  "carbsPercentage": <float>,
                  "fatsPercentage": <float>,
                  "cheatMealsPerWeek": <integer 1-3>,
                  "meals": [{
                    "mealName": "<string>",
                    "mealType": "<BREAKFAST|LUNCH|DINNER|SNACK>",
                    "description": "<brief description>",
                    "calories": <integer>,
                    "proteinG": <float>,
                    "carbsG": <float>,
                    "fatsG": <float>,
                    "recipeInstructions": "<step-by-step cooking instructions>"
                  }]
                }
                """;
    }

    private String buildNutritionUserPrompt(AiNutritionPlanContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        sb.append("PROFILE: ");
        List<String> profileParts = new ArrayList<>();
        if (profile.getGender() != null) profileParts.add(profile.getGender());
        if (profile.getAgeYears() != null) profileParts.add("age " + profile.getAgeYears());
        if (profile.getFitnessLevel() != null) profileParts.add(profile.getFitnessLevel());
        if (profile.getCurrentWeightKg() != null) profileParts.add(profile.getCurrentWeightKg() + "kg");
        if (profile.getHeightCm() != null) profileParts.add(profile.getHeightCm() + "cm");
        sb.append(String.join(", ", profileParts)).append("\n");

        if (profile.getTargetWeightKg() != null) {
            sb.append("TARGET WEIGHT: ").append(profile.getTargetWeightKg()).append("kg\n");
        }

        if (context.getGoalName() != null) {
            sb.append("GOAL: ").append(context.getGoalName()).append("\n");
        }

        if (context.getDietaryPreferences() != null && !context.getDietaryPreferences().isBlank()) {
            sb.append("DIETARY PREFERENCES: ").append(context.getDietaryPreferences()).append("\n");
        }

        if (context.getDietaryRestrictions() != null && !context.getDietaryRestrictions().isBlank()) {
            sb.append("DIETARY RESTRICTIONS: ").append(context.getDietaryRestrictions()).append("\n");
        }

        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty()) {
            sb.append("HEALTH CONDITIONS: ").append(String.join(", ", profile.getHealthLimitations())).append("\n");
        }

        // Include activity level from schedule if available
        if (profile.getScheduleDays() != null && !profile.getScheduleDays().isEmpty()) {
            sb.append("ACTIVITY: ").append(profile.getScheduleDays().size()).append(" workout days/week\n");
        }

        if (context.getAdditionalNotes() != null && !context.getAdditionalNotes().isBlank()) {
            sb.append("NOTES: ").append(context.getAdditionalNotes()).append("\n");
        }

        sb.append("\nGenerate the nutrition plan JSON.");
        return sb.toString();
    }

    private String buildNutritionAdjustmentSystemPrompt() {
        return """
                You are a certified nutritionist specializing in adaptive nutrition planning. \
                Analyze nutrition behavior data and adjust plans to optimize progress toward the user's goal.

                ADJUSTMENT FRAMEWORK:
                - Adherence < 50% → Simplify meals, reduce calorie gap from maintenance
                - Adherence 50-80% → Maintain targets, suggest easier meal preps
                - Adherence > 80% + weight trending wrong → Adjust calories by ±100-200
                - Adherence > 80% + weight on track → Maintain current plan with variety
                - Avg intake consistently below target → Reduce target slightly, add calorie-dense snacks
                - Avg intake consistently above target → Increase protein %, suggest volume foods

                RULES:
                - Respond with valid JSON ONLY. No markdown.
                - Exactly 4 meals (BREAKFAST, LUNCH, DINNER, SNACK)
                - Respect dietary restrictions and health conditions
                - Explain reasoning in "recommendationReason"
                - Minimum 1200 calories for any plan

                JSON SCHEMA:
                {
                  "planName": "<string>",
                  "description": "<string>",
                  "recommendationReason": "<string explaining what changed and why>",
                  "dailyCalorieTarget": <integer>,
                  "proteinPercentage": <float>,
                  "carbsPercentage": <float>,
                  "fatsPercentage": <float>,
                  "cheatMealsPerWeek": <integer 1-3>,
                  "meals": [{
                    "mealName": "<string>",
                    "mealType": "<BREAKFAST|LUNCH|DINNER|SNACK>",
                    "description": "<string>",
                    "calories": <integer>,
                    "proteinG": <float>,
                    "carbsG": <float>,
                    "fatsG": <float>,
                    "recipeInstructions": "<string>"
                  }]
                }
                """;
    }

    private String buildNutritionAdjustmentUserPrompt(AiNutritionPlanContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        sb.append("PROFILE: ");
        List<String> parts = new ArrayList<>();
        if (profile.getGender() != null) parts.add(profile.getGender());
        if (profile.getAgeYears() != null) parts.add("age " + profile.getAgeYears());
        if (profile.getFitnessLevel() != null) parts.add(profile.getFitnessLevel());
        if (profile.getCurrentWeightKg() != null) parts.add(profile.getCurrentWeightKg() + "kg");
        sb.append(String.join(", ", parts)).append("\n");

        if (context.getGoalName() != null) {
            sb.append("GOAL: ").append(context.getGoalName()).append("\n");
        }

        sb.append("CURRENT PLAN: ").append(context.getCurrentPlanName()).append("\n");
        if (context.getCurrentDailyCalorieTarget() != null) {
            sb.append("CURRENT CALORIES: ").append(context.getCurrentDailyCalorieTarget()).append("\n");
        }
        if (context.getCurrentProteinPercentage() != null) {
            sb.append("CURRENT MACROS: P").append(context.getCurrentProteinPercentage())
                    .append("% / C").append(context.getCurrentCarbsPercentage())
                    .append("% / F").append(context.getCurrentFatsPercentage()).append("%\n");
        }

        sb.append("\nMETRICS (last 7 days):\n");
        if (context.getNutritionAdherence() != null) {
            sb.append("- Logging adherence: ").append(String.format("%.0f%%", context.getNutritionAdherence() * 100)).append("\n");
        }
        if (context.getAvgCalorieIntake() != null) {
            sb.append("- Avg daily calorie intake: ").append(String.format("%.0f", context.getAvgCalorieIntake())).append("\n");
        }
        if (context.getWeightTrend() != null) {
            sb.append("- Weight trend: ").append(context.getWeightTrend()).append("\n");
        }

        if (context.getDietaryPreferences() != null && !context.getDietaryPreferences().isBlank()) {
            sb.append("DIETARY PREFERENCES: ").append(context.getDietaryPreferences()).append("\n");
        }
        if (context.getDietaryRestrictions() != null && !context.getDietaryRestrictions().isBlank()) {
            sb.append("DIETARY RESTRICTIONS: ").append(context.getDietaryRestrictions()).append("\n");
        }

        sb.append("\nGenerate the adjusted nutrition plan JSON.");
        return sb.toString();
    }

    // ==================== ASYNC VARIANTS ====================

    @Override
    @Async("aiTaskExecutor")
    public CompletableFuture<AiStructureResult> generateWorkoutStructureAsync(
            AiPlanGenerationContext context) {
        return CompletableFuture.completedFuture(generateWorkoutStructure(context));
    }

    @Override
    @Async("aiTaskExecutor")
    public CompletableFuture<AiNutritionPlanResult> generateNutritionPlanAsync(
            AiNutritionPlanContext context) {
        return CompletableFuture.completedFuture(generateNutritionPlan(context));
    }
}
