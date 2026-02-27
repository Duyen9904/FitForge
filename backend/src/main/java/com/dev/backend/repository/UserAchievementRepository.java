package com.dev.backend.repository;

import com.dev.backend.model.entity.UserAchievement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for user achievements (UC-10)
 */
@Repository
public interface UserAchievementRepository extends JpaRepository<UserAchievement, Long> {

    /**
     * Find all achievements for a user
     */
    List<UserAchievement> findByUserUserIdOrderByEarnedDateDesc(Long userId);

    /**
     * Find specific user achievement
     */
    Optional<UserAchievement> findByUserUserIdAndAchievementAchievementId(Long userId, Long achievementId);

    /**
     * Check if user has already earned an achievement
     */
    boolean existsByUserUserIdAndAchievementAchievementId(Long userId, Long achievementId);

    /**
     * Get total points for a user
     */
    @Query("SELECT COALESCE(SUM(ua.achievement.points), 0) FROM UserAchievement ua WHERE ua.user.userId = :userId")
    Integer getTotalPoints(@Param("userId") Long userId);

    /**
     * Count total achievements for a user
     */
    Long countByUserUserId(Long userId);

    /**
     * Find displayed achievements for a user (for profile display)
     */
    List<UserAchievement> findByUserUserIdAndIsDisplayedTrueOrderByEarnedDateDesc(Long userId);

    /**
     * Get recently earned achievements
     */
    List<UserAchievement> findTop5ByUserUserIdOrderByEarnedDateDesc(Long userId);
}
