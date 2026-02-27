package com.dev.backend.controller;

import com.dev.backend.model.dto.request.CreateExerciseRequest;
import com.dev.backend.model.dto.request.ExerciseFilterRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.service.ExerciseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/exercises")
@Tag(name = "Exercises", description = "Exercise library management endpoints")
public class ExerciseController {

    private final ExerciseService exerciseService;
    private final com.dev.backend.service.RecommendationService recommendationService;

    public ExerciseController(ExerciseService exerciseService,
                              com.dev.backend.service.RecommendationService recommendationService) {
        this.exerciseService = exerciseService;
        this.recommendationService = recommendationService;
    }

    @Operation(summary = "Browse exercises", description = "UC-4.1: Browse and filter available exercises")
    @GetMapping
    public ApiResponse<Page<ExerciseSummaryResponse>> browseExercises(
            @ModelAttribute ExerciseFilterRequest filter,
            @PageableDefault(size = 20, sort = "exerciseName", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ExerciseSummaryResponse> response = exerciseService.browseExercises(filter, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get exercise types", description = "Get all available exercise types with exercise counts")
    @GetMapping("/types")
    public ApiResponse<List<ExerciseTypeResponse>> getExerciseTypes() {
        List<ExerciseTypeResponse> types = exerciseService.getAllExerciseTypes();
        return ApiResponse.success(types);
    }

    @Operation(summary = "Get exercise categories", description = "Get all muscle group categories with exercise counts")
    @GetMapping("/categories")
    public ApiResponse<List<ExerciseCategoryResponse>> getExerciseCategories() {
        List<ExerciseCategoryResponse> categories = exerciseService.getAllExerciseCategories();
        return ApiResponse.success(categories);
    }

    @Operation(summary = "Get exercise details", description = "UC-4.2: View comprehensive exercise information")
    @GetMapping("/{exerciseId}")
    public ApiResponse<ExerciseResponse> getExerciseById(@PathVariable Long exerciseId) {
        ExerciseResponse response = exerciseService.getExerciseById(exerciseId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Add exercise to favorites", description = "UC-4.3: Save exercise to favorites list")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/{exerciseId}/favorites")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<Void> addToFavorites(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long exerciseId) {
        Long userId = Long.parseLong(jwt.getSubject());
        exerciseService.addToFavorites(userId, exerciseId);
        return ApiResponse.success(null, "Exercise added to favorites");
    }

    @Operation(summary = "Remove exercise from favorites", description = "Remove exercise from favorites list")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/{exerciseId}/favorites")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> removeFromFavorites(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long exerciseId) {
        Long userId = Long.parseLong(jwt.getSubject());
        exerciseService.removeFromFavorites(userId, exerciseId);
        return ApiResponse.success(null, "Exercise removed from favorites");
    }

    @Operation(summary = "Check if exercise is favorited", description = "Check if exercise is in user's favorites")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/{exerciseId}/favorites/status")
    public ApiResponse<Boolean> isFavorite(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long exerciseId) {
        Long userId = Long.parseLong(jwt.getSubject());
        boolean isFavorite = exerciseService.isFavorite(userId, exerciseId);
        return ApiResponse.success(isFavorite);
    }

    @Operation(summary = "Get user's favorite exercises", description = "Get all exercises in user's favorites")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/favorites")
    public ApiResponse<Page<ExerciseSummaryResponse>> getUserFavorites(
            @AuthenticationPrincipal Jwt jwt,
            @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<ExerciseSummaryResponse> response = exerciseService.getUserFavorites(userId, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get alternative exercises", description = "UC-4.4: Find substitute exercises")
    @GetMapping("/{exerciseId}/alternatives")
    public ApiResponse<List<ExerciseAlternativeResponse>> getAlternatives(@PathVariable Long exerciseId) {
        List<ExerciseAlternativeResponse> response = exerciseService.getAlternatives(exerciseId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get exercise recommendations", description = "UC-12.3: Get AI-powered exercise suggestions based on user context including current session, fitness goal, fitness level, and historical preferences")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/recommendations")
    public ApiResponse<java.util.List<com.dev.backend.model.dto.response.ExerciseRecommendationResponse>> getRecommendations(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(required = false) Long sessionId,
            @RequestParam(defaultValue = "10") int limit) {
        Long userId = Long.parseLong(jwt.getSubject());
        java.util.List<com.dev.backend.model.dto.response.ExerciseRecommendationResponse> response =
                recommendationService.getExerciseRecommendations(userId, sessionId, limit);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Create a new exercise", description = "UC-4.5: Admin/Trainer creates new exercise")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ExerciseResponse> createExercise(@Valid @RequestBody CreateExerciseRequest request) {
        ExerciseResponse response = exerciseService.createExercise(request);
        return ApiResponse.success(response, "Exercise created successfully");
    }

    // ============= Admin Endpoints (UC-16.1) =============

    @Operation(summary = "Update an exercise", description = "UC-16.1: Admin updates exercise details, videos, images, and muscle group mappings")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{exerciseId}")
    public ApiResponse<ExerciseResponse> updateExercise(
            @PathVariable Long exerciseId,
            @Valid @RequestBody com.dev.backend.model.dto.request.UpdateExerciseRequest request) {
        ExerciseResponse response = exerciseService.updateExercise(exerciseId, request);
        return ApiResponse.success(response, "Exercise updated successfully");
    }

    @Operation(summary = "Delete an exercise", description = "UC-16.1: Admin deletes exercise (only if not in use)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{exerciseId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteExercise(@PathVariable Long exerciseId) {
        exerciseService.deleteExercise(exerciseId);
        return ApiResponse.success(null, "Exercise deleted successfully");
    }

    @Operation(summary = "Check if exercise is in use", description = "UC-16.1: Check if exercise can be deleted")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{exerciseId}/in-use")
    public ApiResponse<Boolean> isExerciseInUse(@PathVariable Long exerciseId) {
        boolean inUse = exerciseService.isExerciseInUse(exerciseId);
        return ApiResponse.success(inUse);
    }

    @Operation(summary = "Add alternative exercise", description = "UC-16.1: Admin adds alternative exercise relationship")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{exerciseId}/alternatives/{alternativeId}")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<Void> addAlternativeExercise(
            @PathVariable Long exerciseId,
            @PathVariable Long alternativeId,
            @RequestParam(required = false) String reason) {
        exerciseService.addAlternativeExercise(exerciseId, alternativeId, reason);
        return ApiResponse.success(null, "Alternative exercise added successfully");
    }

    @Operation(summary = "Remove alternative exercise", description = "UC-16.1: Admin removes alternative exercise relationship")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{exerciseId}/alternatives/{alternativeId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> removeAlternativeExercise(
            @PathVariable Long exerciseId,
            @PathVariable Long alternativeId) {
        exerciseService.removeAlternativeExercise(exerciseId, alternativeId);
        return ApiResponse.success(null, "Alternative exercise removed successfully");
    }
}
