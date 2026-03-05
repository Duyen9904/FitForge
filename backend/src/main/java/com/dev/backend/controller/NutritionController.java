package com.dev.backend.controller;

import com.dev.backend.mapper.NutritionMapper;
import com.dev.backend.model.dto.request.*;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.entity.MealTemplate;
import com.dev.backend.model.entity.NutritionPlan;
import com.dev.backend.service.NutritionRecommendationService;
import com.dev.backend.service.NutritionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/nutrition")
@Tag(name = "Nutrition Management", description = "Nutrition planning, meal logging, and tracking endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class NutritionController {

    private final NutritionService nutritionService;
    private final NutritionRecommendationService nutritionRecommendationService;
    private final NutritionMapper nutritionMapper;

    public NutritionController(NutritionService nutritionService,
                               NutritionRecommendationService nutritionRecommendationService,
                               NutritionMapper nutritionMapper) {
        this.nutritionService = nutritionService;
        this.nutritionRecommendationService = nutritionRecommendationService;
        this.nutritionMapper = nutritionMapper;
    }

    // ========== Nutrition Plans (UC-7.1) ==========

    @Operation(summary = "Create nutrition plan", description = "UC-7.1: Set up personalized meal plan")
    @PostMapping("/plans")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<NutritionPlanResponse> createNutritionPlan(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreateNutritionPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionPlanResponse response = nutritionService.createNutritionPlan(userId, request);
        return ApiResponse.success(response, "Nutrition plan created successfully");
    }

    @Operation(summary = "Get active nutrition plan", description = "Get current active nutrition plan")
    @GetMapping("/plans/active")
    public ApiResponse<NutritionPlanResponse> getActivePlan(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionPlanResponse response = nutritionService.getActivePlan(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Update nutrition plan", description = "Update existing nutrition plan")
    @PutMapping("/plans/{planId}")
    public ApiResponse<NutritionPlanResponse> updateNutritionPlan(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @Valid @RequestBody UpdateNutritionPlanRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionPlanResponse response = nutritionService.updateNutritionPlan(userId, planId, request);
        return ApiResponse.success(response, "Nutrition plan updated successfully");
    }

    @Operation(summary = "Generate recommended nutrition plan",
               description = "Generate a nutrition plan based on onboarding profile using Mifflin-St Jeor equation and goal-based adjustments")
    @PostMapping("/plans/generate")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<NutritionPlanResponse> generateRecommendedPlan(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionPlan plan = nutritionRecommendationService.generateInitialPlan(userId);
        NutritionPlanResponse response = nutritionMapper.toResponse(plan);
        return ApiResponse.success(response, "Nutrition plan generated successfully");
    }

    @Operation(summary = "Adjust nutrition plan based on behavior",
               description = "Analyze recent nutrition logs (adherence, calorie trends) and adjust the plan accordingly")
    @PostMapping("/plans/{planId}/adjust")
    public ApiResponse<NutritionPlanResponse> adjustPlanBasedOnBehavior(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionPlan plan = nutritionRecommendationService.adjustPlanBasedOnBehavior(userId, planId);
        NutritionPlanResponse response = nutritionMapper.toResponse(plan);
        return ApiResponse.success(response, "Nutrition plan adjusted based on behavior");
    }

    @Operation(summary = "Get or generate meals for specific day",
               description = "Get meal templates for a specific day. If not exists, generates them on-demand.")
    @GetMapping("/plans/{planId}/meals/day/{dayNumber}")
    public ApiResponse<List<MealTemplateResponse>> getMealsForDay(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long planId,
            @PathVariable int dayNumber) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<MealTemplate> meals = nutritionRecommendationService.getOrGenerateMealsForDay(userId, planId, dayNumber);
        List<MealTemplateResponse> responses = meals.stream()
                .map(nutritionMapper::toResponse)
                .collect(Collectors.toList());
        return ApiResponse.success(responses, "Meal templates retrieved successfully");
    }

    // ========== Meal Logging (UC-7.2, UC-7.7) ==========

    @Operation(summary = "Log a meal", description = "UC-7.2: Record food intake")
    @PostMapping("/meals")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<NutritionLogResponse> logMeal(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody LogMealRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionLogResponse response = nutritionService.logMeal(userId, request);
        return ApiResponse.success(response, "Meal logged successfully");
    }

    @Operation(summary = "Log meal from template", description = "UC-7.7: Quick log using saved template")
    @PostMapping("/meals/from-template")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<NutritionLogResponse> logMealFromTemplate(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody LogMealFromTemplateRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionLogResponse response = nutritionService.logMealFromTemplate(userId, request);
        return ApiResponse.success(response, "Meal logged from template successfully");
    }

    @Operation(summary = "Get daily meals", description = "Get meal logs for a specific date")
    @GetMapping("/meals")
    public ApiResponse<List<NutritionLogResponse>> getDailyMeals(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Date (YYYY-MM-DD), defaults to today")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<NutritionLogResponse> response = nutritionService.getDailyLogs(userId, date);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get daily nutrition summary", description = "Get calories/macros summary for a date")
    @GetMapping("/summary")
    public ApiResponse<DailyNutritionSummaryResponse> getDailySummary(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Date (YYYY-MM-DD), defaults to today")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Long userId = Long.parseLong(jwt.getSubject());
        DailyNutritionSummaryResponse response = nutritionService.getDailySummary(userId, date);
        return ApiResponse.success(response);
    }

    // ========== Cheat Meal Management (UC-7.3, UC-7.4) ==========

    @Operation(summary = "Get uncompensated cheat meals", description = "UC-7.3: View cheat meals needing compensation")
    @GetMapping("/cheat-meals")
    public ApiResponse<List<CheatMealLogResponse>> getUncompensatedCheatMeals(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<CheatMealLogResponse> response = nutritionService.getUncompensatedCheatMeals(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get compensation options", description = "UC-7.4: Generate compensation strategies")
    @GetMapping("/cheat-meals/{cheatMealLogId}/compensation-options")
    public ApiResponse<List<CompensationActionResponse>> getCompensationOptions(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long cheatMealLogId) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<CompensationActionResponse> response = nutritionService.generateCompensationOptions(userId, cheatMealLogId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Select compensation strategy", description = "UC-7.4: Choose and apply compensation")
    @PostMapping("/cheat-meals/{cheatMealLogId}/compensation")
    public ApiResponse<CompensationActionResponse> selectCompensation(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long cheatMealLogId,
            @Valid @RequestBody SelectCompensationRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        CompensationActionResponse response = nutritionService.selectCompensation(userId, cheatMealLogId, request);
        return ApiResponse.success(response, "Compensation strategy selected");
    }

    // ========== Dashboard (UC-7.5) ==========

    @Operation(summary = "Get nutrition dashboard", description = "UC-7.5: View comprehensive nutrition status")
    @GetMapping("/dashboard")
    public ApiResponse<NutritionDashboardResponse> getDashboard(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionDashboardResponse response = nutritionService.getDashboard(userId);
        return ApiResponse.success(response);
    }

    // ========== Meal Templates (UC-7.6) ==========

    @Operation(summary = "Get meal templates", description = "List all system-provided meal templates")
    @GetMapping("/templates")
    public ApiResponse<List<MealTemplateResponse>> getMealTemplates() {
        List<MealTemplateResponse> response = nutritionService.getMealTemplates();
        return ApiResponse.success(response);
    }

    // ========== Weekly View ==========

    @Operation(summary = "Get weekly nutrition totals", description = "Get daily nutrition summaries for a week range")
    @GetMapping("/weekly")
    public ApiResponse<List<DailyNutritionSummaryResponse>> getWeeklyTotals(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Week start date (YYYY-MM-DD), defaults to current week Monday")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart) {
        Long userId = Long.parseLong(jwt.getSubject());
        LocalDate start = weekStart != null ? weekStart : LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        LocalDate end = start.plusDays(6);
        List<DailyNutritionSummaryResponse> response = nutritionService.getWeeklyTotals(userId, start, end);
        return ApiResponse.success(response);
    }

}
