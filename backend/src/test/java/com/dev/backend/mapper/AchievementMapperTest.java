package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.AchievementResponse;
import com.dev.backend.model.dto.response.UserAchievementResponse;
import com.dev.backend.model.entity.Achievement;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserAchievement;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;

class AchievementMapperTest {

    private AchievementMapper achievementMapper;

    @BeforeEach
    void setUp() {
        achievementMapper = new AchievementMapper();
    }

    @Nested
    @DisplayName("toResponse tests")
    class ToResponseTests {

        @Test
        @DisplayName("Should map achievement entity to response")
        void toResponse_MapsCorrectly() {
            Achievement entity = new Achievement();
            entity.setAchievementId(1L);
            entity.setAchievementName("First Workout");
            entity.setDescription("Complete your first workout session");
            entity.setBadgeIconUrl("/badges/first_workout.png");
            entity.setCriteria("Complete 1 workout");
            entity.setPoints(100);
            entity.setCategory("WORKOUT");

            AchievementResponse response = achievementMapper.toResponse(entity);

            assertThat(response.getAchievementId()).isEqualTo(1L);
            assertThat(response.getAchievementName()).isEqualTo("First Workout");
            assertThat(response.getDescription()).isEqualTo("Complete your first workout session");
            assertThat(response.getBadgeIconUrl()).isEqualTo("/badges/first_workout.png");
            assertThat(response.getCriteria()).isEqualTo("Complete 1 workout");
            assertThat(response.getPoints()).isEqualTo(100);
            assertThat(response.getCategory()).isEqualTo("WORKOUT");
            assertThat(response.getIsEarned()).isFalse();
            assertThat(response.getProgressPercent()).isEqualTo(0.0);
        }

        @Test
        @DisplayName("Should handle null optional fields")
        void toResponse_NullFields() {
            Achievement entity = new Achievement();
            entity.setAchievementId(2L);
            entity.setAchievementName("Mystery Badge");
            entity.setDescription(null);
            entity.setBadgeIconUrl(null);
            entity.setCriteria(null);
            entity.setPoints(50);
            entity.setCategory("MILESTONE");

            AchievementResponse response = achievementMapper.toResponse(entity);

            assertThat(response.getAchievementId()).isEqualTo(2L);
            assertThat(response.getDescription()).isNull();
            assertThat(response.getBadgeIconUrl()).isNull();
            assertThat(response.getCriteria()).isNull();
        }
    }

    @Nested
    @DisplayName("toResponseWithProgress tests")
    class ToResponseWithProgressTests {

        @Test
        @DisplayName("Should map with earned status and progress")
        void toResponseWithProgress_Earned() {
            Achievement entity = new Achievement();
            entity.setAchievementId(1L);
            entity.setAchievementName("Century Club");
            entity.setDescription("Complete 100 workouts");
            entity.setPoints(500);
            entity.setCategory("MILESTONE");

            AchievementResponse response = achievementMapper.toResponseWithProgress(
                    entity, true, "2026-01-15", 100.0, "100/100 workouts completed");

            assertThat(response.getIsEarned()).isTrue();
            assertThat(response.getEarnedDate()).isEqualTo("2026-01-15");
            assertThat(response.getProgressPercent()).isEqualTo(100.0);
            assertThat(response.getProgressDescription()).isEqualTo("100/100 workouts completed");
        }

        @Test
        @DisplayName("Should map with partial progress")
        void toResponseWithProgress_InProgress() {
            Achievement entity = new Achievement();
            entity.setAchievementId(2L);
            entity.setAchievementName("Iron Pumper");
            entity.setDescription("Lift 10,000 kg total volume");
            entity.setPoints(300);
            entity.setCategory("STRENGTH");

            AchievementResponse response = achievementMapper.toResponseWithProgress(
                    entity, false, null, 45.5, "4,550/10,000 kg lifted");

            assertThat(response.getIsEarned()).isFalse();
            assertThat(response.getEarnedDate()).isNull();
            assertThat(response.getProgressPercent()).isEqualTo(45.5);
            assertThat(response.getProgressDescription()).isEqualTo("4,550/10,000 kg lifted");
        }
    }

    @Nested
    @DisplayName("toUserAchievementResponse tests")
    class ToUserAchievementResponseTests {

        @Test
        @DisplayName("Should map user achievement with achievement details")
        void toUserAchievementResponse_MapsCorrectly() {
            User user = new User();
            user.setUserId(1L);

            Achievement achievement = new Achievement();
            achievement.setAchievementId(1L);
            achievement.setAchievementName("7-Day Streak");
            achievement.setDescription("Workout 7 days in a row");
            achievement.setBadgeIconUrl("/badges/streak_7.png");
            achievement.setPoints(200);
            achievement.setCategory("CONSISTENCY");

            UserAchievement userAchievement = new UserAchievement();
            userAchievement.setUserAchievementId(10L);
            userAchievement.setUser(user);
            userAchievement.setAchievement(achievement);
            userAchievement.setEarnedDate(Instant.parse("2026-01-10T12:00:00Z"));
            userAchievement.setIsDisplayed(true);

            UserAchievementResponse response = achievementMapper.toUserAchievementResponse(userAchievement);

            assertThat(response.getUserAchievementId()).isEqualTo(10L);
            assertThat(response.getAchievementId()).isEqualTo(1L);
            assertThat(response.getAchievementName()).isEqualTo("7-Day Streak");
            assertThat(response.getDescription()).isEqualTo("Workout 7 days in a row");
            assertThat(response.getBadgeIconUrl()).isEqualTo("/badges/streak_7.png");
            assertThat(response.getPoints()).isEqualTo(200);
            assertThat(response.getCategory()).isEqualTo("CONSISTENCY");
            assertThat(response.getEarnedDate()).isEqualTo(Instant.parse("2026-01-10T12:00:00Z"));
            assertThat(response.getIsDisplayed()).isTrue();
        }

        @Test
        @DisplayName("Should handle hidden achievement")
        void toUserAchievementResponse_Hidden() {
            User user = new User();
            user.setUserId(1L);

            Achievement achievement = new Achievement();
            achievement.setAchievementId(5L);
            achievement.setAchievementName("Secret Badge");
            achievement.setPoints(1000);

            UserAchievement userAchievement = new UserAchievement();
            userAchievement.setUserAchievementId(15L);
            userAchievement.setUser(user);
            userAchievement.setAchievement(achievement);
            userAchievement.setEarnedDate(Instant.now());
            userAchievement.setIsDisplayed(false);

            UserAchievementResponse response = achievementMapper.toUserAchievementResponse(userAchievement);

            assertThat(response.getIsDisplayed()).isFalse();
        }
    }
}
