package com.dev.backend.controller;

import com.dev.backend.model.dto.request.SubmitOnboardingStepRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingProgressResponse;
import com.dev.backend.service.OnboardingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

/**
 * User-facing onboarding endpoints (UC-17).
 */
@RestController
@RequestMapping("/api/v1/onboarding")
@Tag(name = "Onboarding", description = "User onboarding flow endpoints")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class OnboardingController {

    private final OnboardingService onboardingService;

    @Operation(summary = "Get onboarding flow",
               description = "UC-17.1: Get all onboarding steps with user's current progress. Each step includes inputType (TEXT, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, TOGGLE) for choosing the correct UI component.")
    @GetMapping("/flow")
    public ApiResponse<OnboardingFlowResponse> getOnboardingFlow(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        OnboardingFlowResponse flow = onboardingService.getOnboardingFlow(userId);
        return ApiResponse.success(flow);
    }

    @Operation(summary = "Submit step response",
               description = "UC-17.2-9: Submit user's response for an onboarding step. Response includes inputType for the submitted step.")
    @PostMapping("/steps/{stepId}/submit")
    public ApiResponse<OnboardingProgressResponse> submitStepResponse(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long stepId,
            @RequestBody SubmitOnboardingStepRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        OnboardingProgressResponse progress = onboardingService.submitStepResponse(userId, stepId, request);
        return ApiResponse.success(progress, "Step completed successfully");
    }

    @Operation(summary = "Skip optional step",
               description = "UC-17.10: Skip a non-required onboarding step. Response includes inputType for the skipped step.")
    @PostMapping("/steps/{stepId}/skip")
    public ApiResponse<OnboardingProgressResponse> skipStep(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long stepId) {
        Long userId = Long.parseLong(jwt.getSubject());
        OnboardingProgressResponse progress = onboardingService.skipStep(userId, stepId);
        return ApiResponse.success(progress, "Step skipped");
    }

    @Operation(summary = "Complete onboarding", 
               description = "UC-17.13: Mark onboarding as complete after all required steps are done")
    @PostMapping("/complete")
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> completeOnboarding(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        onboardingService.completeOnboarding(userId);
        return ApiResponse.success(null, "Onboarding completed successfully");
    }
}
