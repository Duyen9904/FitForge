package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Response DTO for user's earned achievement (UC-10.1, UC-10.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserAchievementResponse {
    
    private Long userAchievementId;
    private Long achievementId;
    private String achievementName;
    private String description;
    private String badgeIconUrl;
    private Integer points;
    private String category;
    private Instant earnedDate;
    private Boolean isDisplayed;
}
