package com.dev.backend.service;

import com.dev.backend.model.dto.request.ShareAchievementRequest;
import com.dev.backend.model.dto.response.AchievementGalleryResponse;
import com.dev.backend.model.dto.response.AchievementResponse;
import com.dev.backend.model.dto.response.ShareAchievementResponse;
import com.dev.backend.model.dto.response.UserAchievementResponse;
import com.dev.backend.model.enums.AchievementTrigger;

import java.util.List;

/**
 * Service interface for Achievement & Gamification (UC-10)
 */
public interface AchievementService {

    // ========== UC-10.1: Earn Achievement ==========

    /**
     * Check if user qualifies for any achievements based on trigger
     * Called after workout completion, nutrition logging, etc.
     */
    List<UserAchievementResponse> checkAndAwardAchievements(Long userId, AchievementTrigger trigger);

    /**
     * Manually check all achievements for a user
     */
    List<UserAchievementResponse> checkAllAchievements(Long userId);

    // ========== UC-10.2: View Achievement Gallery ==========

    /**
     * Get achievement gallery with earned and locked achievements
     */
    AchievementGalleryResponse getAchievementGallery(Long userId);

    /**
     * Get all earned achievements for a user
     */
    List<UserAchievementResponse> getEarnedAchievements(Long userId);

    /**
     * Get all available achievements (for reference)
     */
    List<AchievementResponse> getAllAchievements();

    /**
     * Get achievements by category
     */
    List<AchievementResponse> getAchievementsByCategory(Long userId, String category);

    /**
     * Get total points for a user
     */
    Integer getTotalPoints(Long userId);

    // ========== UC-10.3: Share Achievement ==========

    /**
     * Generate shareable content for an achievement
     */
    ShareAchievementResponse shareAchievement(Long userId, Long achievementId, ShareAchievementRequest request);

    // ========== Display Preferences ==========

    /**
     * Toggle whether an achievement is displayed on profile
     */
    UserAchievementResponse toggleAchievementDisplay(Long userId, Long achievementId, boolean isDisplayed);

    /**
     * Get achievement progress for a specific achievement
     */
    AchievementResponse getAchievementProgress(Long userId, Long achievementId);
}
