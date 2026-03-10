package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.AchievementMapper;
import com.dev.backend.model.dto.request.ShareAchievementRequest;
import com.dev.backend.model.dto.response.AchievementGalleryResponse;
import com.dev.backend.model.dto.response.AchievementResponse;
import com.dev.backend.model.dto.response.ShareAchievementResponse;
import com.dev.backend.model.dto.response.UserAchievementResponse;
import com.dev.backend.model.entity.Achievement;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserAchievement;
import com.dev.backend.model.enums.AchievementTrigger;
import com.dev.backend.repository.*;
import com.dev.backend.service.AchievementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Implementation of AchievementService for UC-10: Achievement & Gamification
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AchievementServiceImpl implements AchievementService {

    private final AchievementRepository achievementRepository;
    private final UserAchievementRepository userAchievementRepository;
    private final UserRepository userRepository;
    private final WorkoutProgressRepository workoutProgressRepository;
    private final PlanMealRepository planMealRepository;
    private final UserMeasurementRepository userMeasurementRepository;
    private final AchievementMapper achievementMapper;

    private static final DateTimeFormatter ISO_FORMATTER = DateTimeFormatter.ISO_INSTANT;

    // ========== UC-10.1: Earn Achievement ==========

    @Override
    @Transactional
    public List<UserAchievementResponse> checkAndAwardAchievements(Long userId, AchievementTrigger trigger) {
        log.info("Checking achievements for user {} with trigger {}", userId, trigger);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        List<UserAchievementResponse> awardedAchievements = new ArrayList<>();

        // Check if achievement criteria is met based on trigger
        Achievement achievement = findAchievementByTrigger(trigger);
        if (achievement != null && !hasEarnedAchievement(userId, achievement.getAchievementId())) {
            if (checkAchievementCriteria(userId, trigger)) {
                UserAchievement userAchievement = awardAchievement(user, achievement);
                awardedAchievements.add(achievementMapper.toUserAchievementResponse(userAchievement));
                log.info("Awarded achievement '{}' to user {}", achievement.getAchievementName(), userId);
            }
        }

        return awardedAchievements;
    }

    @Override
    @Transactional
    public List<UserAchievementResponse> checkAllAchievements(Long userId) {
        log.info("Checking all achievements for user {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        List<UserAchievementResponse> awardedAchievements = new ArrayList<>();

        // Check all triggers
        for (AchievementTrigger trigger : AchievementTrigger.values()) {
            Achievement achievement = findAchievementByTrigger(trigger);
            if (achievement != null && !hasEarnedAchievement(userId, achievement.getAchievementId())) {
                if (checkAchievementCriteria(userId, trigger)) {
                    UserAchievement userAchievement = awardAchievement(user, achievement);
                    awardedAchievements.add(achievementMapper.toUserAchievementResponse(userAchievement));
                    log.info("Awarded achievement '{}' to user {}", achievement.getAchievementName(), userId);
                }
            }
        }

        return awardedAchievements;
    }

    // ========== UC-10.2: View Achievement Gallery ==========

    @Override
    public AchievementGalleryResponse getAchievementGallery(Long userId) {
        log.debug("Getting achievement gallery for user {}", userId);

        // Get all achievements
        List<Achievement> allAchievements = achievementRepository.findAll();
        
        // Get user's earned achievements
        List<UserAchievement> earnedAchievements = userAchievementRepository
                .findByUserUserIdOrderByEarnedDateDesc(userId);
        
        Set<Long> earnedIds = earnedAchievements.stream()
                .map(ua -> ua.getAchievement().getAchievementId())
                .collect(Collectors.toSet());

        // Map earned achievements
        List<UserAchievementResponse> earnedResponses = earnedAchievements.stream()
                .map(achievementMapper::toUserAchievementResponse)
                .collect(Collectors.toList());

        // Map locked achievements with progress
        List<AchievementResponse> lockedResponses = allAchievements.stream()
                .filter(a -> !earnedIds.contains(a.getAchievementId()))
                .map(a -> buildAchievementWithProgress(userId, a))
                .collect(Collectors.toList());

        // Get recently earned (last 5)
        List<UserAchievementResponse> recentlyEarned = userAchievementRepository
                .findTop5ByUserUserIdOrderByEarnedDateDesc(userId)
                .stream()
                .map(achievementMapper::toUserAchievementResponse)
                .collect(Collectors.toList());

        // Get near completion (highest progress, top 5)
        List<AchievementResponse> nearCompletion = lockedResponses.stream()
                .filter(a -> a.getProgressPercent() != null && a.getProgressPercent() > 0)
                .sorted((a, b) -> Double.compare(b.getProgressPercent(), a.getProgressPercent()))
                .limit(5)
                .collect(Collectors.toList());

        // Calculate stats
        Integer totalPoints = userAchievementRepository.getTotalPoints(userId);
        double completionPercent = allAchievements.isEmpty() ? 0.0 : 
                (earnedAchievements.size() * 100.0) / allAchievements.size();

        return AchievementGalleryResponse.builder()
                .earnedAchievements(earnedResponses)
                .earnedCount(earnedAchievements.size())
                .lockedAchievements(lockedResponses)
                .lockedCount(lockedResponses.size())
                .totalAchievements(allAchievements.size())
                .totalPoints(totalPoints != null ? totalPoints : 0)
                .completionPercent(Math.round(completionPercent * 100.0) / 100.0)
                .recentlyEarned(recentlyEarned)
                .nearCompletion(nearCompletion)
                .build();
    }

    @Override
    public List<UserAchievementResponse> getEarnedAchievements(Long userId) {
        return userAchievementRepository.findByUserUserIdOrderByEarnedDateDesc(userId)
                .stream()
                .map(achievementMapper::toUserAchievementResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AchievementResponse> getAllAchievements() {
        return achievementRepository.findAll().stream()
                .map(achievementMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AchievementResponse> getAchievementsByCategory(Long userId, String category) {
        List<Achievement> achievements = achievementRepository.findByCategory(category);
        
        Set<Long> earnedIds = userAchievementRepository.findByUserUserIdOrderByEarnedDateDesc(userId)
                .stream()
                .map(ua -> ua.getAchievement().getAchievementId())
                .collect(Collectors.toSet());

        return achievements.stream()
                .map(a -> {
                    if (earnedIds.contains(a.getAchievementId())) {
                        Optional<UserAchievement> ua = userAchievementRepository
                                .findByUserUserIdAndAchievementAchievementId(userId, a.getAchievementId());
                        String earnedDate = ua.map(u -> ISO_FORMATTER.format(u.getEarnedDate())).orElse(null);
                        return achievementMapper.toResponseWithProgress(a, true, earnedDate, 100.0, "Completed!");
                    } else {
                        return buildAchievementWithProgress(userId, a);
                    }
                })
                .collect(Collectors.toList());
    }

    @Override
    public Integer getTotalPoints(Long userId) {
        Integer points = userAchievementRepository.getTotalPoints(userId);
        return points != null ? points : 0;
    }

    // ========== UC-10.3: Share Achievement ==========

    @Override
    public ShareAchievementResponse shareAchievement(Long userId, Long achievementId, 
            ShareAchievementRequest request) {
        log.info("User {} sharing achievement {} on {}", userId, achievementId, request.getPlatform());

        // Verify user has earned this achievement
        UserAchievement userAchievement = userAchievementRepository
                .findByUserUserIdAndAchievementAchievementId(userId, achievementId)
                .orElseThrow(() -> new ResourceNotFoundException("UserAchievement", 
                        "userId/achievementId", userId + "/" + achievementId));

        Achievement achievement = userAchievement.getAchievement();

        // Generate shareable content
        String shareableLink = generateShareableLink(userId, achievementId);
        String shareableImageUrl = achievement.getBadgeIconUrl();
        String message = buildShareMessage(achievement, request.getCustomMessage());

        return ShareAchievementResponse.builder()
                .success(true)
                .shareableLink(shareableLink)
                .shareableImageUrl(shareableImageUrl)
                .platform(request.getPlatform())
                .message(message)
                .build();
    }

    // ========== Display Preferences ==========

    @Override
    @Transactional
    public UserAchievementResponse toggleAchievementDisplay(Long userId, Long achievementId, 
            boolean isDisplayed) {
        UserAchievement userAchievement = userAchievementRepository
                .findByUserUserIdAndAchievementAchievementId(userId, achievementId)
                .orElseThrow(() -> new ResourceNotFoundException("UserAchievement", 
                        "userId/achievementId", userId + "/" + achievementId));

        userAchievement.setIsDisplayed(isDisplayed);
        userAchievement = userAchievementRepository.save(userAchievement);
        
        return achievementMapper.toUserAchievementResponse(userAchievement);
    }

    @Override
    public AchievementResponse getAchievementProgress(Long userId, Long achievementId) {
        Achievement achievement = achievementRepository.findById(achievementId)
                .orElseThrow(() -> new ResourceNotFoundException("Achievement", "id", achievementId));

        Optional<UserAchievement> earned = userAchievementRepository
                .findByUserUserIdAndAchievementAchievementId(userId, achievementId);

        if (earned.isPresent()) {
            String earnedDate = ISO_FORMATTER.format(earned.get().getEarnedDate());
            return achievementMapper.toResponseWithProgress(achievement, true, earnedDate, 100.0, "Completed!");
        } else {
            return buildAchievementWithProgress(userId, achievement);
        }
    }

    // ========== Helper Methods ==========

    private Achievement findAchievementByTrigger(AchievementTrigger trigger) {
        return achievementRepository.findByAchievementName(trigger.getAchievementName()).orElse(null);
    }

    private boolean hasEarnedAchievement(Long userId, Long achievementId) {
        return userAchievementRepository.existsByUserUserIdAndAchievementAchievementId(userId, achievementId);
    }

    private UserAchievement awardAchievement(User user, Achievement achievement) {
        UserAchievement userAchievement = new UserAchievement();
        userAchievement.setUser(user);
        userAchievement.setAchievement(achievement);
        userAchievement.setEarnedDate(Instant.now());
        userAchievement.setIsDisplayed(true);
        return userAchievementRepository.save(userAchievement);
    }

    private boolean checkAchievementCriteria(Long userId, AchievementTrigger trigger) {
        switch (trigger) {
            case FIRST_WORKOUT:
                return workoutProgressRepository.countCompletedByUserId(userId) >= 1;
            
            case WORKOUTS_10:
                return workoutProgressRepository.countCompletedByUserId(userId) >= 10;
            
            case WORKOUTS_50:
                return workoutProgressRepository.countCompletedByUserId(userId) >= 50;
            
            case WORKOUTS_100:
                return workoutProgressRepository.countCompletedByUserId(userId) >= 100;
            
            case STREAK_7_DAYS:
                return checkWorkoutStreak(userId, 7);
            
            case STREAK_30_DAYS:
                return checkWorkoutStreak(userId, 30);
            
            case MEALS_7_DAYS:
                return checkNutritionStreak(userId, 7);
            
            case MEALS_30_DAYS:
                return checkNutritionStreak(userId, 30);
            
            case WEIGHT_GOAL_REACHED:
                return checkWeightGoalReached(userId);
            
            case VOLUME_10000KG:
                // Would need to calculate total volume from exercise logs
                // For now, return false - can be enhanced later
                return false;
            
            case ADHERENCE_80_PERCENT:
                return checkAdherence(userId, 80, 8);
            
            case RECOVERY_LOGGED_7_DAYS:
                // Recovery feature removed
                return false;
            
            case CALORIES_TARGET_MET_7_DAYS:
                // Would need to compare daily calories vs target for 7 days
                return false;
            
            default:
                return false;
        }
    }

    private boolean checkWorkoutStreak(Long userId, int requiredDays) {
        LocalDate today = LocalDate.now();
        for (int i = 0; i < requiredDays; i++) {
            LocalDate date = today.minusDays(i);
            Instant startOfDay = date.atStartOfDay(ZoneId.systemDefault()).toInstant();
            Instant endOfDay = date.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
            
            long count = workoutProgressRepository.countByUserUserIdAndWorkoutDateBetween(
                    userId, startOfDay, endOfDay);
            if (count == 0) {
                return false;
            }
        }
        return true;
    }

    private boolean checkNutritionStreak(Long userId, int requiredDays) {
        LocalDate today = LocalDate.now();
        for (int i = 0; i < requiredDays; i++) {
            LocalDate date = today.minusDays(i);
            List<?> logs = planMealRepository.findByUserUserIdAndScheduledDate(userId, date);
            if (logs.isEmpty()) {
                return false;
            }
        }
        return true;
    }

    private boolean checkWeightGoalReached(Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || user.getTargetWeightKg() == null) {
            return false;
        }
        
        return userMeasurementRepository.findTopByUserUserIdOrderByMeasurementDateDesc(userId)
                .map(measurement -> {
                    if (measurement.getWeightKg() == null) return false;
                    double currentWeight = measurement.getWeightKg().doubleValue();
                    double targetWeight = user.getTargetWeightKg().doubleValue();
                    // Allow 1kg tolerance
                    return Math.abs(currentWeight - targetWeight) <= 1.0;
                })
                .orElse(false);
    }

    private boolean checkAdherence(Long userId, int requiredPercent, int weeks) {
        LocalDate today = LocalDate.now();
        LocalDate startDate = today.minusWeeks(weeks);
        
        Instant start = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
        Instant end = today.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
        
        long completedWorkouts = workoutProgressRepository.countByUserUserIdAndWorkoutDateBetween(userId, start, end);
        
        // Assume expected workouts = 4 per week
        long expectedWorkouts = weeks * 4L;
        if (expectedWorkouts == 0) return false;
        
        double adherence = (completedWorkouts * 100.0) / expectedWorkouts;
        return adherence >= requiredPercent;
    }

    private AchievementResponse buildAchievementWithProgress(Long userId, Achievement achievement) {
        // Determine progress based on achievement type
        AchievementTrigger trigger = findTriggerForAchievement(achievement.getAchievementName());
        
        double progress = 0.0;
        String progressDesc = "";

        if (trigger != null) {
            ProgressInfo progressInfo = calculateProgress(userId, trigger);
            progress = progressInfo.percent;
            progressDesc = progressInfo.description;
        }

        return achievementMapper.toResponseWithProgress(achievement, false, null, progress, progressDesc);
    }

    private AchievementTrigger findTriggerForAchievement(String achievementName) {
        for (AchievementTrigger trigger : AchievementTrigger.values()) {
            if (trigger.getAchievementName().equals(achievementName)) {
                return trigger;
            }
        }
        return null;
    }

    private ProgressInfo calculateProgress(Long userId, AchievementTrigger trigger) {
        long current = 0;
        long required = trigger.getThreshold();

        switch (trigger) {
            case FIRST_WORKOUT:
            case WORKOUTS_10:
            case WORKOUTS_50:
            case WORKOUTS_100:
                current = workoutProgressRepository.countCompletedByUserId(userId);
                break;
            
            case STREAK_7_DAYS:
            case STREAK_30_DAYS:
                current = calculateCurrentStreak(userId);
                break;
            
            case MEALS_7_DAYS:
            case MEALS_30_DAYS:
                current = calculateNutritionStreak(userId);
                break;
            
            default:
                break;
        }

        double percent = required > 0 ? Math.min((current * 100.0) / required, 100.0) : 0.0;
        String description = current + "/" + required;

        return new ProgressInfo(percent, description);
    }

    private long calculateCurrentStreak(Long userId) {
        LocalDate today = LocalDate.now();
        long streak = 0;
        
        for (int i = 0; i < 365; i++) { // Max 1 year lookback
            LocalDate date = today.minusDays(i);
            Instant startOfDay = date.atStartOfDay(ZoneId.systemDefault()).toInstant();
            Instant endOfDay = date.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
            
            long count = workoutProgressRepository.countByUserUserIdAndWorkoutDateBetween(
                    userId, startOfDay, endOfDay);
            if (count > 0) {
                streak++;
            } else if (i > 0) { // Allow today to be incomplete
                break;
            }
        }
        return streak;
    }

    private long calculateNutritionStreak(Long userId) {
        LocalDate today = LocalDate.now();
        long streak = 0;
        
        for (int i = 0; i < 365; i++) {
            LocalDate date = today.minusDays(i);
            List<?> logs = planMealRepository.findByUserUserIdAndScheduledDate(userId, date);
            if (!logs.isEmpty()) {
                streak++;
            } else if (i > 0) {
                break;
            }
        }
        return streak;
    }

    private String generateShareableLink(Long userId, Long achievementId) {
        // In a real implementation, this would generate a public shareable URL
        return String.format("https://gymplan.app/achievements/share/%d/%d", userId, achievementId);
    }

    private String buildShareMessage(Achievement achievement, String customMessage) {
        String baseMessage = String.format("I just earned the '%s' achievement on GymPlan! 🏆 %s",
                achievement.getAchievementName(), 
                achievement.getDescription() != null ? achievement.getDescription() : "");
        
        if (customMessage != null && !customMessage.isBlank()) {
            return customMessage + " " + baseMessage;
        }
        return baseMessage;
    }

    private static class ProgressInfo {
        final double percent;
        final String description;

        ProgressInfo(double percent, String description) {
            this.percent = percent;
            this.description = description;
        }
    }
}
