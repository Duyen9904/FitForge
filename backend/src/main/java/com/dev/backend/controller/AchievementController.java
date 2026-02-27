package com.dev.backend.controller;

import com.dev.backend.model.dto.request.ShareAchievementRequest;
import com.dev.backend.model.dto.response.AchievementGalleryResponse;
import com.dev.backend.model.dto.response.AchievementResponse;
import com.dev.backend.model.dto.response.ShareAchievementResponse;
import com.dev.backend.model.dto.response.UserAchievementResponse;
import com.dev.backend.service.AchievementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for Achievement & Gamification (UC-10)
 */
@RestController
@RequestMapping("/api/v1/achievements")
@RequiredArgsConstructor
@Tag(name = "Achievements", description = "Endpoints for achievement and gamification features")
public class AchievementController {

    private final AchievementService achievementService;

    // ========== UC-10.2: View Achievement Gallery ==========

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get all achievements", description = "Get all available achievements with progress info")
    public ResponseEntity<List<AchievementResponse>> getAllAchievements(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(achievementService.getAllAchievements());
    }

    @GetMapping("/gallery")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get achievement gallery", description = "Get gallery with earned and locked achievements")
    public ResponseEntity<AchievementGalleryResponse> getAchievementGallery(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.getAchievementGallery(userId));
    }

    @GetMapping("/earned")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get earned achievements", description = "Get all achievements earned by user")
    public ResponseEntity<List<UserAchievementResponse>> getEarnedAchievements(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.getEarnedAchievements(userId));
    }

    @GetMapping("/category/{category}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get achievements by category", description = "Get achievements filtered by category")
    public ResponseEntity<List<AchievementResponse>> getAchievementsByCategory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String category) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.getAchievementsByCategory(userId, category));
    }

    @GetMapping("/{achievementId}/progress")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get achievement progress", description = "Get progress toward a specific achievement")
    public ResponseEntity<AchievementResponse> getAchievementProgress(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long achievementId) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.getAchievementProgress(userId, achievementId));
    }

    @GetMapping("/points")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get total points", description = "Get user's total achievement points")
    public ResponseEntity<Integer> getTotalPoints(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.getTotalPoints(userId));
    }

    // ========== UC-10.3: Share Achievement ==========

    @PostMapping("/{achievementId}/share")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Share achievement", description = "Generate shareable content for an achievement")
    public ResponseEntity<ShareAchievementResponse> shareAchievement(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long achievementId,
            @Valid @RequestBody ShareAchievementRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.shareAchievement(userId, achievementId, request));
    }

    // ========== Display Preferences ==========

    @PutMapping("/{achievementId}/display")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Toggle achievement display", description = "Toggle whether an achievement is displayed on profile")
    public ResponseEntity<UserAchievementResponse> toggleAchievementDisplay(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long achievementId,
            @RequestParam boolean display) {
        Long userId = Long.parseLong(jwt.getSubject());
        return ResponseEntity.ok(achievementService.toggleAchievementDisplay(userId, achievementId, display));
    }
}
