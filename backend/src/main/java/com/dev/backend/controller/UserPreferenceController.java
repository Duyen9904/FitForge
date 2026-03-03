package com.dev.backend.controller;

import com.dev.backend.model.dto.request.UpdateUserPreferenceRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.UserPreferenceResponse;
import com.dev.backend.service.UserPreferenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users/me/preferences")
@Tag(name = "User Preferences", description = "User preference management endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
@RequiredArgsConstructor
public class UserPreferenceController {

    private final UserPreferenceService userPreferenceService;

    @Operation(summary = "Get user preferences",
               description = "Get the authenticated user's preferences (workout, nutrition, notifications, units)")
    @GetMapping
    public ApiResponse<UserPreferenceResponse> getUserPreferences(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        UserPreferenceResponse response = userPreferenceService.getUserPreferences(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Update user preferences",
               description = "Update user preferences. Only non-null fields are applied (partial update).")
    @PutMapping
    public ApiResponse<UserPreferenceResponse> updateUserPreferences(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody UpdateUserPreferenceRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        UserPreferenceResponse response = userPreferenceService.updateUserPreferences(userId, request);
        return ApiResponse.success(response, "Preferences updated successfully");
    }
}
