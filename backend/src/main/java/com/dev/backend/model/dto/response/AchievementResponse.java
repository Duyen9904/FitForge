package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for achievement definition (UC-10)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AchievementResponse {
    
    private Long achievementId;
    private String achievementName;
    private String description;
    private String badgeIconUrl;
    private String criteria;
    private Integer points;
    private String category;
    private Boolean isEarned; // For user context
    private String earnedDate; // ISO date if earned
    private Double progressPercent; // 0-100 progress toward achievement
    private String progressDescription; // e.g., "7/100 workouts completed"
}
