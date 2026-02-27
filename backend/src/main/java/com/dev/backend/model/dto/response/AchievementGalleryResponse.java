package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for achievement gallery view (UC-10.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AchievementGalleryResponse {
    
    // Earned achievements
    private List<UserAchievementResponse> earnedAchievements;
    private Integer earnedCount;
    
    // Locked (not yet earned) achievements with progress
    private List<AchievementResponse> lockedAchievements;
    private Integer lockedCount;
    
    // Total stats
    private Integer totalAchievements;
    private Integer totalPoints;
    private Double completionPercent; // % of achievements earned
    
    // Recently earned (last 5)
    private List<UserAchievementResponse> recentlyEarned;
    
    // Close to earning (highest progress)
    private List<AchievementResponse> nearCompletion;
}
