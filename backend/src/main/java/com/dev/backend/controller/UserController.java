package com.dev.backend.controller;

import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users", description = "User profile and settings management endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @Operation(summary = "Get current user profile", description = "Get the authenticated user's profile including primary fitness goal")
    @GetMapping("/me")
    public ApiResponse<UserProfileResponse> getCurrentUserProfile(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        UserProfileResponse response = userService.getCurrentUserProfile(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Set primary fitness goal", description = "UC-12.2: Set user's main training objective. System will adjust recommendations based on goal including exercise suggestions, rep/set schemes, nutrition targets, and rest day frequency.")
    @PutMapping("/me/primary-goal")
    public ApiResponse<UserProfileResponse> setPrimaryGoal(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody SetPrimaryGoalRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        UserProfileResponse response = userService.setPrimaryGoal(userId, request);
        return ApiResponse.success(response, "Primary fitness goal updated successfully");
    }
}
