package com.dev.backend.controller;

import com.dev.backend.model.dto.request.CreateGoalRequest;
import com.dev.backend.model.dto.request.UpdateGoalRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.service.GoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/goals")
@Tag(name = "Goals", description = "Fitness goal management endpoints")
public class GoalController {

    private final GoalService goalService;

    public GoalController(GoalService goalService) {
        this.goalService = goalService;
    }

    @Operation(summary = "Browse fitness goals", description = "UC-12.1: View available fitness goal templates including Muscle Gain, Fat Loss, Strength, Endurance, and General Fitness")
    @GetMapping
    public ApiResponse<List<GoalResponse>> getAllGoals() {
        List<GoalResponse> goals = goalService.getAllGoals();
        return ApiResponse.success(goals);
    }

    @Operation(summary = "Get goal details", description = "Get detailed information about a specific fitness goal including recommended rep range, rest time, frequency, and calorie adjustments")
    @GetMapping("/{goalId}")
    public ApiResponse<GoalResponse> getGoalById(@PathVariable Long goalId) {
        GoalResponse goal = goalService.getGoalById(goalId);
        return ApiResponse.success(goal);
    }

    // ============= Admin Endpoints (UC-16.2) =============

    @Operation(summary = "Create a goal template", description = "UC-16.2: Admin creates new fitness goal template")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<GoalResponse> createGoal(@Valid @RequestBody CreateGoalRequest request) {
        GoalResponse goal = goalService.createGoal(request);
        return ApiResponse.success(goal, "Goal created successfully");
    }

    @Operation(summary = "Update a goal template", description = "UC-16.2: Admin updates goal parameters")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{goalId}")
    public ApiResponse<GoalResponse> updateGoal(
            @PathVariable Long goalId,
            @Valid @RequestBody UpdateGoalRequest request) {
        GoalResponse goal = goalService.updateGoal(goalId, request);
        return ApiResponse.success(goal, "Goal updated successfully");
    }

    @Operation(summary = "Delete a goal template", description = "UC-16.2: Admin deletes goal (only if not in use)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{goalId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteGoal(@PathVariable Long goalId) {
        goalService.deleteGoal(goalId);
        return ApiResponse.success(null, "Goal deleted successfully");
    }

    @Operation(summary = "Check if goal is in use", description = "UC-16.2: Check if goal can be deleted")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{goalId}/in-use")
    public ApiResponse<Boolean> isGoalInUse(@PathVariable Long goalId) {
        boolean inUse = goalService.isGoalInUse(goalId);
        return ApiResponse.success(inUse);
    }
}
