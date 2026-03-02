package com.dev.backend.service.impl;

import com.dev.backend.model.dto.ai.*;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.repository.ExerciseRepository;
import com.dev.backend.service.AiService;
import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.chat.completions.ChatCompletion;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import com.openai.models.chat.completions.ChatCompletionToolMessageParam;
import jakarta.annotation.PostConstruct;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

/**
 * AI service implementation using OpenRouter (OpenAI-compatible API).
 * Uses a 2-step agent loop with tool calling:
 *   Step 1: AI calls search_exercises → we query ExerciseDB and return results
 *   Step 2: AI calls create_plan using real exercises → we parse as AiWorkoutPlanResult
 */
@Service
@Slf4j
public class OpenRouterAiServiceImpl implements AiService {

    private static final int MAX_AGENT_ITERATIONS = 5;

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
    private final ExerciseRepository exerciseRepository;
    private OpenAIClient client;

    public OpenRouterAiServiceImpl(ObjectMapper objectMapper, ExerciseRepository exerciseRepository) {
        this.objectMapper = objectMapper;
        this.exerciseRepository = exerciseRepository;
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

    // ==================== TOOL DEFINITIONS ====================

    /**
     * Tool: search_exercises
     * The AI calls this to query available exercises from ExerciseDB.
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonClassDescription(
            "Query the exercise database for real, verified exercises. "
            + "MUST be called BEFORE CreatePlanTool. "
            + "Returns exercise objects with exact names you must use in the plan. "
            + "Search by bodyParts matching the user's target muscle groups, "
            + "and optionally filter by the user's available equipment.")
    public static class SearchExercisesTool {
        @JsonPropertyDescription(
                "Muscle group categories to search (required, at least 1). "
                + "ONLY these exact values are valid: "
                + "CHEST, BACK, SHOULDERS, ARMS, LEGS, CORE, GLUTES.")
        private List<String> bodyParts;

        @JsonPropertyDescription(
                "Equipment category filter (optional). "
                + "ONLY these exact values are valid: "
                + "FREE_WEIGHTS, MACHINE, BODYWEIGHT, ACCESSORIES.")
        private List<String> equipment;

        @JsonPropertyDescription("Max exercises per body-part query (1–20, default 10).")
        private Integer limit;
    }

    /**
     * Tool: create_plan
     * The AI calls this to output the final workout plan using exercises from search results.
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonClassDescription(
            "Output the final 7-day workout plan. "
            + "MUST be called AFTER SearchExercisesTool. "
            + "Every exerciseName MUST exactly match a name returned by the search. "
            + "Include exactly 7 sessions (dayNumber 1–7). "
            + "Non-training days: isRestDay=true, exercises=[].")
    public static class CreatePlanTool {
        @JsonPropertyDescription("Short, descriptive plan name (e.g. 'Strength Builder – Week 1')")
        private String planName;

        @JsonPropertyDescription("1–2 sentence summary: who the plan is for, what it targets, expected outcomes")
        private String description;

        @JsonPropertyDescription("Explain the reasoning: why these exercises, this split, this volume for this user")
        private String recommendationReason;

        @JsonPropertyDescription(
                "Exactly 7 session objects (dayNumber 1–7). "
                + "Workout sessions: 4–6 exercises each. "
                + "Rest sessions: isRestDay=true, exercises=[].")
        private List<AiSessionResult> sessions;
    }

    // ==================== GENERATION (AGENT LOOP) ====================

    @Override
    public AiWorkoutPlanResult generateWorkoutPlan(AiPlanGenerationContext context) {
        if (client == null) {
            throw new IllegalStateException("OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.");
        }

        log.info("[AI-AGENT] Starting agent-based plan generation for user {} | Goal: {} | Frequency: {}/week",
                context.getProfile().getUserId(),
                context.getGoalName(),
                context.getFrequencyPerWeek());

        String systemPrompt = buildAgentSystemPrompt();
        String userPrompt = buildGenerationUserPrompt(context);

        long totalStart = System.currentTimeMillis();

        // Build initial request with tools
        ChatCompletionCreateParams.Builder paramsBuilder = ChatCompletionCreateParams.builder()
                .model(model)
                .maxTokens(maxTokens)
                .temperature(temperature)
                .addTool(SearchExercisesTool.class)
                .addTool(CreatePlanTool.class)
                .addSystemMessage(systemPrompt)
                .addUserMessage(userPrompt);

        AiWorkoutPlanResult result = null;

        // Agent loop: iterate until create_plan is called or max iterations reached
        for (int iteration = 1; iteration <= MAX_AGENT_ITERATIONS; iteration++) {
            log.info("[AI-AGENT] Iteration {}/{}", iteration, MAX_AGENT_ITERATIONS);

            ChatCompletion completion = callAiWithTools(paramsBuilder.build());

            if (completion.choices().isEmpty()) {
                throw new RuntimeException("AI returned no choices");
            }

            var choice = completion.choices().get(0);
            var message = choice.message();

            // Add assistant message to conversation history
            paramsBuilder.addMessage(message);

            // Check if there's text content (shouldn't happen with tools, but log it)
            message.content().ifPresent(content -> {
                log.info("[AI-AGENT] Assistant text: {}", content);
            });

            // Process tool calls
            var toolCalls = message.toolCalls().orElse(List.of());
            if (toolCalls.isEmpty()) {
                // No tool calls — the model responded with text instead
                log.warn("[AI-AGENT] No tool calls in iteration {}. Finish reason: {}", iteration, choice.finishReason());
                // Try to parse the content as JSON (fallback to old behavior)
                String content = message.content().orElse(null);
                if (content != null) {
                    log.info("[AI-AGENT] Falling back to parsing text response as JSON");
                    result = parseResponse(content);
                    break;
                }
                continue;
            }

            for (var toolCall : toolCalls) {
                var function = toolCall.asFunction().function();
                String toolName = function.name();

                log.info("[AI-AGENT] Tool call: {} (id: {})", toolName, toolCall.asFunction().id());

                if ("SearchExercisesTool".equals(toolName)) {
                    // Step 1: Execute exercise search
                    SearchExercisesTool params = function.arguments(SearchExercisesTool.class);
                    SearchExercisesToolResult searchResult = executeSearchExercises(params);

                    log.info("[AI-AGENT] Search returned {} exercises", searchResult.getExercises().size());

                    // Feed results back to the LLM
                    paramsBuilder.addMessage(ChatCompletionToolMessageParam.builder()
                            .toolCallId(toolCall.asFunction().id())
                            .contentAsJson(searchResult)
                            .build());

                } else if ("CreatePlanTool".equals(toolName)) {
                    // Step 2: Parse the plan from tool call arguments
                    CreatePlanTool planTool = function.arguments(CreatePlanTool.class);
                    result = AiWorkoutPlanResult.builder()
                            .planName(planTool.getPlanName())
                            .description(planTool.getDescription())
                            .recommendationReason(planTool.getRecommendationReason())
                            .sessions(planTool.getSessions())
                            .build();

                    log.info("[AI-AGENT] Plan created: '{}' with {} sessions",
                            result.getPlanName(),
                            result.getSessions() != null ? result.getSessions().size() : 0);

                    // Acknowledge the tool call (required by the API)
                    paramsBuilder.addMessage(ChatCompletionToolMessageParam.builder()
                            .toolCallId(toolCall.asFunction().id())
                            .content("Plan created successfully.")
                            .build());

                    break; // Plan received, exit agent loop

                } else {
                    log.warn("[AI-AGENT] Unknown tool call: {}", toolName);
                    paramsBuilder.addMessage(ChatCompletionToolMessageParam.builder()
                            .toolCallId(toolCall.asFunction().id())
                            .content("Error: Unknown tool '" + toolName + "'")
                            .build());
                }
            }

            // If we got a plan, break out of the loop
            if (result != null) {
                break;
            }
        }

        if (result == null) {
            throw new RuntimeException("AI agent failed to produce a plan within " + MAX_AGENT_ITERATIONS + " iterations.");
        }

        long totalMs = System.currentTimeMillis() - totalStart;
        int sessionCount = result.getSessions() != null ? result.getSessions().size() : 0;
        log.info("[AI-AGENT] Completed in {} ms | Plan: '{}' | Sessions: {}",
                totalMs, result.getPlanName(), sessionCount);

        return result;
    }

    // ==================== ADJUSTMENT (unchanged — still single-shot) ====================

    @Override
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
        String jsonResponse = callAiSingleShot(systemPrompt, userPrompt);
        AiWorkoutPlanResult result = parseResponse(jsonResponse);
        long totalMs = System.currentTimeMillis() - totalStart;

        int sessionCount = result.getSessions() != null ? result.getSessions().size() : 0;
        log.info("[AI-ADJUST] Completed in {} ms | Plan: '{}' | Sessions generated: {}",
                totalMs, result.getPlanName(), sessionCount);
        return result;
    }

    // ==================== EXERCISE SEARCH EXECUTION ====================

    /**
     * Execute the search_exercises tool call by querying the LOCAL exercise database.
     */
    private SearchExercisesToolResult executeSearchExercises(SearchExercisesTool params) {
        int limit = (params.getLimit() != null && params.getLimit() > 0) ? params.getLimit() : 10;
        Set<Long> seenIds = new HashSet<>();
        List<SearchExercisesToolResult.ExerciseInfo> allExercises = new ArrayList<>();

        // Search by muscle group category (body parts)
        if (params.getBodyParts() != null) {
            for (String bodyPart : params.getBodyParts()) {
                String category = bodyPart.trim().toUpperCase();
                log.info("[AI-AGENT] Searching local DB for muscle group category: '{}', limit: {}", category, limit);
                try {
                    List<Exercise> results = exerciseRepository.findByMuscleGroupCategory(category);
                    if (results != null) {
                        results.stream().limit(limit).forEach(ex -> {
                            if (seenIds.add(ex.getExerciseId())) {
                                allExercises.add(SearchExercisesToolResult.ExerciseInfo.builder()
                                        .id(String.valueOf(ex.getExerciseId()))
                                        .name(ex.getExerciseName())
                                        .target(category.toLowerCase())
                                        .bodyPart(category.toLowerCase())
                                        .equipment(ex.getEquipmentCategory())
                                        .build());
                            }
                        });
                    }
                } catch (Exception e) {
                    log.warn("[AI-AGENT] Failed to search local DB by category '{}': {}", category, e.getMessage());
                }
            }
        }

        // Search by equipment category (only if body parts didn't return enough)
        if (params.getEquipment() != null && allExercises.size() < limit * 2) {
            for (String equip : params.getEquipment()) {
                log.info("[AI-AGENT] Searching local DB for equipment: '{}', limit: {}", equip, limit);
                try {
                    List<Exercise> results = exerciseRepository.findByEquipmentCategoryIgnoreCase(equip.trim());
                    if (results != null) {
                        results.stream().limit(limit).forEach(ex -> {
                            if (seenIds.add(ex.getExerciseId())) {
                                allExercises.add(SearchExercisesToolResult.ExerciseInfo.builder()
                                        .id(String.valueOf(ex.getExerciseId()))
                                        .name(ex.getExerciseName())
                                        .target(null)
                                        .bodyPart(null)
                                        .equipment(ex.getEquipmentCategory())
                                        .build());
                            }
                        });
                    }
                } catch (Exception e) {
                    log.warn("[AI-AGENT] Failed to search local DB by equipment '{}': {}", equip, e.getMessage());
                }
            }
        }

        log.info("[AI-AGENT] Total unique exercises found in local DB: {}", allExercises.size());
        return SearchExercisesToolResult.builder().exercises(allExercises).build();
    }

    // ==================== API CALLS ====================

    /**
     * Call the AI with tool definitions (agent mode).
     */
    private ChatCompletion callAiWithTools(ChatCompletionCreateParams params) {
        log.info("========== OPENROUTER AGENT REQUEST ==========");
        log.info("Model: {} | MaxTokens: {} | Temperature: {}", model, maxTokens, temperature);

        long startTime = System.currentTimeMillis();
        ChatCompletion completion = client.chat().completions().create(params);
        long latencyMs = System.currentTimeMillis() - startTime;

        log.info("========== OPENROUTER AGENT RESPONSE ==========");
        log.info("Latency: {} ms ({} seconds)", latencyMs, latencyMs / 1000.0);
        log.info("Response ID: {}", completion.id());
        log.info("Model used: {}", completion.model());

        if (completion.usage().isPresent()) {
            var usage = completion.usage().get();
            log.info("Token usage - Prompt: {} | Completion: {} | Total: {}",
                    usage.promptTokens(), usage.completionTokens(), usage.totalTokens());
        }

        if (!completion.choices().isEmpty()) {
            var firstChoice = completion.choices().get(0);
            log.info("Finish reason: {}", firstChoice.finishReason());
        }

        log.info("==========================================");
        return completion;
    }

    /**
     * Call AI with a simple system + user prompt (single-shot, no tools).
     * Used for adjustWorkoutPlan which doesn't need the agent loop.
     */
    private String callAiSingleShot(String systemPrompt, String userPrompt) {
        log.info("========== OPENROUTER REQUEST ==========");
        log.info("Model: {} | MaxTokens: {} | Temperature: {}", model, maxTokens, temperature);
        log.info("System prompt length: {} chars", systemPrompt.length());
        log.info("User prompt length: {} chars", userPrompt.length());
        log.debug("System prompt:\n{}", systemPrompt);
        log.debug("User prompt:\n{}", userPrompt);

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

        log.info("========== OPENROUTER RESPONSE ==========");
        log.info("Latency: {} ms ({} seconds)", latencyMs, latencyMs / 1000.0);
        log.info("Response ID: {}", completion.id());
        log.info("Model used: {}", completion.model());

        if (completion.usage().isPresent()) {
            var usage = completion.usage().get();
            log.info("Token usage - Prompt: {} | Completion: {} | Total: {}",
                    usage.promptTokens(), usage.completionTokens(), usage.totalTokens());
        } else {
            log.warn("No token usage info returned by OpenRouter");
        }

        if (!completion.choices().isEmpty()) {
            var firstChoice = completion.choices().get(0);
            log.info("Finish reason: {}", firstChoice.finishReason());
        }

        String content = completion.choices().stream()
                .findFirst()
                .flatMap(choice -> choice.message().content())
                .orElseThrow(() -> new RuntimeException("AI returned empty response"));

        log.info("Response content length: {} chars", content.length());
        log.info("Full AI response:\n{}", content);
        log.info("=========================================");
        return content;
    }

    private AiWorkoutPlanResult parseResponse(String jsonContent) {
        try {
            // Strip markdown code fences if present
            String cleaned = jsonContent.trim();
            if (cleaned.startsWith("```json")) {
                cleaned = cleaned.substring(7);
            } else if (cleaned.startsWith("```")) {
                cleaned = cleaned.substring(3);
            }
            if (cleaned.endsWith("```")) {
                cleaned = cleaned.substring(0, cleaned.length() - 3);
            }
            cleaned = cleaned.trim();

            return objectMapper.readValue(cleaned, AiWorkoutPlanResult.class);
        } catch (Exception e) {
            log.error("Failed to parse AI response as JSON: {}", jsonContent, e);
            throw new RuntimeException("Failed to parse AI-generated workout plan. The AI returned invalid JSON.", e);
        }
    }

    // ==================== SYSTEM PROMPTS ====================

    // ==================== AGENT SYSTEM PROMPT ====================

    private String buildAgentSystemPrompt() {
        return """
                # ROLE
                You are a certified personal trainer and exercise physiologist (15+ years). \
                You design safe, periodized training programs matched to individual goals, \
                fitness levels, and available equipment.

                # WORKFLOW (execute these steps IN ORDER — do NOT skip any step)

                ## Step 1 → Search
                Call `SearchExercisesTool` to query real exercises from the local database.
                - Map the user's target muscle groups to valid category values:
                  CHEST | BACK | SHOULDERS | ARMS | LEGS | CORE | GLUTES
                - Optionally filter by equipment category:
                  FREE_WEIGHTS | MACHINE | BODYWEIGHT | ACCESSORIES
                - Set limit=10 per category for a diverse pool.
                Think: "Which muscle group categories cover this user's goals?"

                ## Step 2 → Plan
                Call `CreatePlanTool` to output the final 7-day plan.
                - Think step by step:
                  1. Review the search results and shortlist exercises matching the user's goal.
                  2. Design a weekly split (push/pull/legs, upper/lower, etc.) based on frequency.
                  3. Assign 4–6 exercises per workout session from the shortlist.
                  4. Set sets, reps, rest based on difficulty and goal.
                  5. Verify every exerciseName EXACTLY matches a name from Step 1 results.

                ## Example Flow
                User goal: "Build muscle", target: CHEST + BACK, equipment: FREE_WEIGHTS
                → Step 1: SearchExercisesTool({bodyParts:["CHEST","BACK"], equipment:["FREE_WEIGHTS"], limit:10})
                → Step 2: CreatePlanTool with exercises selected from the returned list

                # CONSTRAINTS

                ## Hard Rules
                - NEVER invent exercise names. Use ONLY exact names from search results.
                - Exactly 7 sessions: dayNumber 1–7. Non-training days = isRestDay:true, exercises:[].
                - Distribute workout days evenly; insert ≥1 rest day between consecutive training days.
                - 4–6 exercises per workout session.

                ## Safety (CRITICAL — violations are unacceptable)
                - Back problems → exclude deadlifts, barbell rows, heavy spinal-loading exercises.
                - Knee problems → exclude deep squats, lunges, box jumps.
                - Shoulder problems → exclude overhead press, behind-neck movements.
                - Always substitute with safe alternatives for any listed health limitation.

                ## Difficulty Matching
                - BEGINNER: compound movements, low volume (3 sets), moderate reps (10–12).
                - INTERMEDIATE: mix of compound + isolation, moderate volume (3–4 sets).
                - ADVANCED: complex splits, higher volume (4–5 sets), varied rep ranges.

                # SELF-VERIFICATION (before calling CreatePlanTool)
                ✓ Every exerciseName exists verbatim in the SearchExercisesTool results
                ✓ Exactly 7 sessions with dayNumber 1–7
                ✓ Rest days match: 7 − frequencyPerWeek = number of rest days
                ✓ No exercise conflicts with listed health limitations
                ✓ Exercise complexity matches the stated difficulty level
                ✓ All exercises are performable with the user's listed equipment
                """;
    }

    private String buildGenerationUserPrompt(AiPlanGenerationContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        // ── User Profile ──
        sb.append("# USER PROFILE\n");
        if (profile.getGender() != null) sb.append("- Gender: ").append(profile.getGender()).append("\n");
        if (profile.getAgeYears() != null) sb.append("- Age: ").append(profile.getAgeYears()).append("\n");
        if (profile.getHeightCm() != null) sb.append("- Height: ").append(profile.getHeightCm()).append(" cm\n");
        if (profile.getCurrentWeightKg() != null) sb.append("- Weight: ").append(profile.getCurrentWeightKg()).append(" kg\n");
        if (profile.getTargetWeightKg() != null) sb.append("- Target weight: ").append(profile.getTargetWeightKg()).append(" kg\n");
        if (profile.getFitnessLevel() != null) sb.append("- Fitness level: ").append(profile.getFitnessLevel()).append("\n");
        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty()) {
            sb.append("- ⚠ Health limitations: ").append(String.join(", ", profile.getHealthLimitations())).append("\n");
        }
        if (profile.getPreferredSessionDuration() != null) {
            sb.append("- Session duration: ").append(profile.getPreferredSessionDuration()).append(" min\n");
        }

        // ── Equipment ──
        sb.append("\n# AVAILABLE EQUIPMENT\n");
        if (context.getAvailableEquipment() != null && !context.getAvailableEquipment().isEmpty()) {
            sb.append(String.join(", ", context.getAvailableEquipment())).append("\n");
        } else {
            sb.append("body weight (no gym equipment)\n");
        }

        // ── Plan Requirements ──
        sb.append("\n# PLAN REQUIREMENTS\n");
        if (context.getGoalName() != null) sb.append("- Goal: ").append(context.getGoalName()).append("\n");
        if (context.getTargetMuscleGroups() != null && !context.getTargetMuscleGroups().isEmpty()) {
            sb.append("- Priority muscle groups: ").append(String.join(", ", context.getTargetMuscleGroups()));
            sb.append(" (emphasize these, but keep a balanced plan)\n");

            // Provide body-part mapping hints for SearchExercisesTool
            sb.append("- Suggested search body parts: ");
            List<String> bodyPartHints = context.getTargetMuscleGroups().stream()
                    .map(mg -> mapMuscleGroupToBodyPart(mg))
                    .filter(Objects::nonNull)
                    .distinct()
                    .collect(Collectors.toList());
            sb.append(String.join(", ", bodyPartHints)).append("\n");
        }
        sb.append("- Frequency: ").append(context.getFrequencyPerWeek()).append(" workout days/week\n");
        sb.append("- Duration: ").append(context.getDurationWeeks()).append(" weeks\n");
        sb.append("- Difficulty: ").append(context.getDifficultyLevel()).append("\n");

        if (context.getWeekNumber() != null && context.getWeekNumber() > 1) {
            sb.append("- Week: ").append(context.getWeekNumber())
              .append(" of ").append(context.getDurationWeeks())
              .append(" (progressive overload vs. earlier weeks)\n");
        } else {
            sb.append("- Week: 1 (foundation week)\n");
        }

        // ── Additional User Request ──
        if (context.getAdditionalInformation() != null && !context.getAdditionalInformation().isBlank()) {
            sb.append("\n# ADDITIONAL USER REQUEST\n");
            sb.append(context.getAdditionalInformation()).append("\n");
        }

        // ── Action Instruction ──
        sb.append("\n# ACTION\n");
        sb.append("Step 1: Call SearchExercisesTool with the suggested body parts and the user's equipment.\n");
        sb.append("Step 2: Review the results, then call CreatePlanTool with the best exercises for this user.\n");

        return sb.toString();
    }

    /**
     * Map muscle group enum names to ExerciseDB body-part values.
     * Used to provide hints in the user prompt for accurate tool calls.
     */
    private String mapMuscleGroupToBodyPart(String muscleGroup) {
        if (muscleGroup == null) return null;
        return switch (muscleGroup.toUpperCase()) {
            case "CHEST" -> "CHEST";
            case "BACK" -> "BACK";
            case "LEGS", "QUADRICEPS", "HAMSTRINGS" -> "LEGS";
            case "SHOULDERS" -> "SHOULDERS";
            case "ARMS", "BICEPS", "TRICEPS" -> "ARMS";
            case "CORE", "ABS", "ABDOMINALS" -> "CORE";
            case "GLUTES" -> "GLUTES";
            default -> muscleGroup.toUpperCase();
        };
    }

    // ==================== ADJUSTMENT PROMPTS ====================

    private String buildAdjustmentSystemPrompt() {
        return """
                You are a certified personal trainer and exercise physiologist specializing in adaptive training. \
                You analyze workout behavior data and adjust plans to optimize progress while preventing burnout and injury.

                YOUR TASK: Analyze the user's behavior metrics, then generate an adjusted 7-day workout week as valid JSON.

                THINK STEP BY STEP:
                1. First, analyze the behavior metrics (adherence, completion, RPE, pain flags).
                2. Then, decide what adjustments are needed using the decision framework below.
                3. Finally, generate the adjusted plan reflecting those decisions.

                ADJUSTMENT DECISION FRAMEWORK:
                - Adherence < 50%  → Reduce frequency by 1 day, simplify exercises, shorten sessions
                - Adherence 50–80% → Maintain frequency, slightly reduce volume if RPE is high
                - Adherence > 80% + RPE < 5 → Increase intensity (weight/sets) or add 1 exercise per session
                - Adherence > 80% + RPE 5–7 → Maintain current level (good balance)
                - Adherence > 80% + RPE > 8 → Reduce volume by 1–2 sets per exercise, add active recovery
                - Pain flags > 0 → Swap exercises targeting the affected area with safe alternatives
                - Low completion rate (<60%) → Reduce exercises per session to 3–4

                Explain your reasoning in the "recommendationReason" field.

                STRICT RULES:
                1. Respond with valid JSON ONLY. No markdown. No explanation text.
                2. ONLY prescribe exercises matching the user's available equipment.
                3. Create exactly 7 session objects (dayNumber 1–7).
                4. Respect health limitations — never prescribe exercises that could aggravate them.

                BEFORE RESPONDING, VERIFY:
                ✓ Adjustments logically match the behavior metrics
                ✓ Exactly 7 sessions with dayNumber 1–7
                ✓ Every exercise matches available equipment
                ✓ No exercise aggravates health limitations
                ✓ recommendationReason explains what changed and why

                JSON SCHEMA (respond with exactly this structure):
                {
                  "planName": "<string>",
                  "description": "<string>",
                  "recommendationReason": "<string explaining adjustments made>",
                  "sessions": [
                    {
                      "dayNumber": <integer 1-7>,
                      "sessionName": "<string>",
                      "focusArea": "<string>",
                      "estimatedDuration": <integer minutes>,
                      "isRestDay": <boolean>,
                      "warmUpNotes": "<string>",
                      "coolDownNotes": "<string>",
                      "exercises": [
                        {
                          "exerciseName": "<string>",
                          "sets": <integer>,
                          "repetitions": "<string>",
                          "weightKg": <number or null>,
                          "restTimeSeconds": <integer>,
                          "orderIndex": <integer>,
                          "notes": "<string>"
                        }
                      ]
                    }
                  ]
                }
                """;
    }

    private String buildAdjustmentUserPrompt(AiPlanAdjustmentContext context) {
        StringBuilder sb = new StringBuilder();
        var profile = context.getProfile();

        // User profile
        sb.append("USER PROFILE:\n");
        if (profile.getGender() != null) sb.append("- Gender: ").append(profile.getGender()).append("\n");
        if (profile.getAgeYears() != null) sb.append("- Age: ").append(profile.getAgeYears()).append(" years\n");
        if (profile.getFitnessLevel() != null) sb.append("- Fitness level: ").append(profile.getFitnessLevel()).append("\n");
        if (profile.getHealthLimitations() != null && !profile.getHealthLimitations().isEmpty()) {
            sb.append("- Health limitations: ").append(String.join(", ", profile.getHealthLimitations())).append("\n");
        }

        // Available equipment
        sb.append("\nAVAILABLE EQUIPMENT:\n");
        if (context.getAvailableEquipment() != null && !context.getAvailableEquipment().isEmpty()) {
            sb.append(String.join(", ", context.getAvailableEquipment())).append("\n");
        } else {
            sb.append("Bodyweight only (no gym equipment).\n");
        }

        // Current plan info
        sb.append("\nCURRENT PLAN:\n");
        if (context.getCurrentPlanName() != null) sb.append("- Plan: ").append(context.getCurrentPlanName()).append("\n");
        sb.append("- Frequency: ").append(context.getFrequencyPerWeek()).append(" days/week\n");
        sb.append("- Difficulty: ").append(context.getDifficultyLevel()).append("\n");
        if (context.getGoalName() != null) sb.append("- Goal: ").append(context.getGoalName()).append("\n");
        if (context.getCurrentPlanSummary() != null) {
            sb.append("- Current sessions:\n").append(context.getCurrentPlanSummary()).append("\n");
        }

        // Behavior metrics
        sb.append("\nBEHAVIOR METRICS (last 2 weeks):\n");
        if (context.getWorkoutAdherence() != null) {
            sb.append("- Adherence: ").append(String.format("%.0f%%", context.getWorkoutAdherence() * 100)).append("\n");
        }
        if (context.getAvgCompletionRate() != null) {
            sb.append("- Avg completion rate: ").append(String.format("%.0f%%", context.getAvgCompletionRate() * 100)).append("\n");
        }
        if (context.getAvgRPE() != null) {
            sb.append("- Avg RPE: ").append(String.format("%.1f", context.getAvgRPE())).append("/10\n");
        }
        if (context.getPainFlagCount() != null && context.getPainFlagCount() > 0) {
            sb.append("- Pain flags: ").append(context.getPainFlagCount()).append("\n");
        }

        sb.append("\nAnalyze the metrics step by step, then generate the adjusted plan JSON.");

        return sb.toString();
    }
}
