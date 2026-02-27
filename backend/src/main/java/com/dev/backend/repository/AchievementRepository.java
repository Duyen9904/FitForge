package com.dev.backend.repository;

import com.dev.backend.model.entity.Achievement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for achievements (UC-10)
 */
@Repository
public interface AchievementRepository extends JpaRepository<Achievement, Long> {

    /**
     * Find achievement by name
     */
    Optional<Achievement> findByAchievementName(String achievementName);

    /**
     * Find all achievements by category
     */
    List<Achievement> findByCategory(String category);

    /**
     * Find all achievements ordered by points
     */
    List<Achievement> findAllByOrderByPointsDesc();

    /**
     * Check if achievement exists by name
     */
    boolean existsByAchievementName(String achievementName);
}
