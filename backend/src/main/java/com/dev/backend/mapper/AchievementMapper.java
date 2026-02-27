package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.AchievementGalleryResponse;
import com.dev.backend.model.dto.response.AchievementResponse;
import com.dev.backend.model.dto.response.UserAchievementResponse;
import com.dev.backend.model.entity.Achievement;
import com.dev.backend.model.entity.UserAchievement;
import org.springframework.stereotype.Component;

import java.time.format.DateTimeFormatter;

/**
 * Mapper for Achievement entities and DTOs
 */
@Component
public class AchievementMapper {

    private static final DateTimeFormatter ISO_FORMATTER = DateTimeFormatter.ISO_INSTANT;

    public AchievementResponse toResponse(Achievement entity) {
        return AchievementResponse.builder()
                .achievementId(entity.getAchievementId())
                .achievementName(entity.getAchievementName())
                .description(entity.getDescription())
                .badgeIconUrl(entity.getBadgeIconUrl())
                .criteria(entity.getCriteria())
                .points(entity.getPoints())
                .category(entity.getCategory())
                .isEarned(false) // Default, will be set by service
                .progressPercent(0.0)
                .progressDescription("")
                .build();
    }

    public AchievementResponse toResponseWithProgress(Achievement entity, boolean isEarned, 
            String earnedDate, Double progressPercent, String progressDescription) {
        return AchievementResponse.builder()
                .achievementId(entity.getAchievementId())
                .achievementName(entity.getAchievementName())
                .description(entity.getDescription())
                .badgeIconUrl(entity.getBadgeIconUrl())
                .criteria(entity.getCriteria())
                .points(entity.getPoints())
                .category(entity.getCategory())
                .isEarned(isEarned)
                .earnedDate(earnedDate)
                .progressPercent(progressPercent)
                .progressDescription(progressDescription)
                .build();
    }

    public UserAchievementResponse toUserAchievementResponse(UserAchievement entity) {
        Achievement achievement = entity.getAchievement();
        return UserAchievementResponse.builder()
                .userAchievementId(entity.getUserAchievementId())
                .achievementId(achievement.getAchievementId())
                .achievementName(achievement.getAchievementName())
                .description(achievement.getDescription())
                .badgeIconUrl(achievement.getBadgeIconUrl())
                .points(achievement.getPoints())
                .category(achievement.getCategory())
                .earnedDate(entity.getEarnedDate())
                .isDisplayed(entity.getIsDisplayed())
                .build();
    }
}
