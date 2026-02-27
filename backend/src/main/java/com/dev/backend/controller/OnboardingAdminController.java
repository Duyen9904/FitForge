package com.dev.backend.controller;

import com.dev.backend.model.dto.request.ReorderOnboardingStepsRequest;
import com.dev.backend.model.dto.request.SaveOnboardingOptionRequest;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.OnboardingAnalyticsResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.service.OnboardingAdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Admin endpoints for onboarding configuration (UC-18).
 */
@RestController
@RequestMapping("/api/v1/admin/onboarding")
@Tag(name = "Onboarding Admin", description = "Admin onboarding configuration endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class OnboardingAdminController {

    private final OnboardingAdminService onboardingAdminService;

    // ============= Step Management =============

    @Operation(summary = "Get all onboarding steps", 
               description = "UC-18.1: Get all onboarding steps for admin configuration")
    @GetMapping("/steps")
    public ApiResponse<List<OnboardingStepResponse>> getAllSteps() {
        List<OnboardingStepResponse> steps = onboardingAdminService.getAllSteps();
        return ApiResponse.success(steps);
    }

    @Operation(summary = "Create onboarding step", 
               description = "UC-18.2: Create a new onboarding step")
    @PostMapping("/steps")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<OnboardingStepResponse> createStep(
            @Valid @RequestBody SaveOnboardingStepRequest request) {
        OnboardingStepResponse step = onboardingAdminService.createStep(request);
        return ApiResponse.success(step, "Step created successfully");
    }

    @Operation(summary = "Update onboarding step", 
               description = "UC-18.3: Update an existing onboarding step")
    @PutMapping("/steps/{stepId}")
    public ApiResponse<OnboardingStepResponse> updateStep(
            @PathVariable Long stepId,
            @Valid @RequestBody SaveOnboardingStepRequest request) {
        OnboardingStepResponse step = onboardingAdminService.updateStep(stepId, request);
        return ApiResponse.success(step, "Step updated successfully");
    }

    @Operation(summary = "Delete onboarding step", 
               description = "UC-18.2: Delete an onboarding step (only if no user data)")
    @DeleteMapping("/steps/{stepId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteStep(@PathVariable Long stepId) {
        onboardingAdminService.deleteStep(stepId);
        return ApiResponse.success(null, "Step deleted successfully");
    }

    @Operation(summary = "Reorder onboarding steps", 
               description = "UC-18.2: Reorder onboarding steps by providing ordered list of IDs")
    @PutMapping("/steps/reorder")
    public ApiResponse<Void> reorderSteps(
            @Valid @RequestBody ReorderOnboardingStepsRequest request) {
        onboardingAdminService.reorderSteps(request);
        return ApiResponse.success(null, "Steps reordered successfully");
    }

    // ============= Option Management =============

    @Operation(summary = "Create option for step", 
               description = "UC-18.4: Create a new option for an onboarding step")
    @PostMapping("/steps/{stepId}/options")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<OnboardingOptionResponse> createOption(
            @PathVariable Long stepId,
            @Valid @RequestBody SaveOnboardingOptionRequest request) {
        OnboardingOptionResponse option = onboardingAdminService.createOption(stepId, request);
        return ApiResponse.success(option, "Option created successfully");
    }

    @Operation(summary = "Update option", 
               description = "UC-18.4: Update an existing option")
    @PutMapping("/options/{optionId}")
    public ApiResponse<OnboardingOptionResponse> updateOption(
            @PathVariable Long optionId,
            @Valid @RequestBody SaveOnboardingOptionRequest request) {
        OnboardingOptionResponse option = onboardingAdminService.updateOption(optionId, request);
        return ApiResponse.success(option, "Option updated successfully");
    }

    @Operation(summary = "Delete option", 
               description = "UC-18.4: Delete an option")
    @DeleteMapping("/options/{optionId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteOption(@PathVariable Long optionId) {
        onboardingAdminService.deleteOption(optionId);
        return ApiResponse.success(null, "Option deleted successfully");
    }

    // ============= Analytics =============

    @Operation(summary = "Get onboarding analytics", 
               description = "UC-18.9: Get onboarding completion analytics for a date range")
    @GetMapping("/analytics")
    public ApiResponse<OnboardingAnalyticsResponse> getAnalytics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        OnboardingAnalyticsResponse analytics = onboardingAdminService.getOnboardingAnalytics(from, to);
        return ApiResponse.success(analytics);
    }
}
