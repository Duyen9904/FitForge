package com.dev.backend.service.impl;

import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.WorkoutSession;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.repository.WorkoutPlanRepository;
import com.dev.backend.repository.WorkoutProgressRepository;
import com.dev.backend.repository.WorkoutSessionRepository;
import com.dev.backend.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

/**
 * Scheduled tasks for generating notifications (UC-15)
 */
@Component
public class NotificationScheduler {

    private static final Logger logger = LoggerFactory.getLogger(NotificationScheduler.class);

    private final NotificationService notificationService;
    private final UserRepository userRepository;
    private final WorkoutProgressRepository workoutProgressRepository;
    private final WorkoutPlanRepository workoutPlanRepository;
    private final WorkoutSessionRepository workoutSessionRepository;

    @Value("${notification.scheduler.enabled:true}")
    private boolean schedulerEnabled;

    public NotificationScheduler(
            NotificationService notificationService,
            UserRepository userRepository,
            WorkoutProgressRepository workoutProgressRepository,
            WorkoutPlanRepository workoutPlanRepository,
            WorkoutSessionRepository workoutSessionRepository) {
        this.notificationService = notificationService;
        this.userRepository = userRepository;
        this.workoutProgressRepository = workoutProgressRepository;
        this.workoutPlanRepository = workoutPlanRepository;
        this.workoutSessionRepository = workoutSessionRepository;
    }

    /**
     * UC-15.2: Check for workout streaks daily at 8 AM
     */
    @Scheduled(cron = "0 0 8 * * *")
    @Transactional(readOnly = true)
    public void checkWorkoutStreaks() {
        if (!schedulerEnabled) {
            return;
        }

        logger.info("Running workout streak check...");

        try {
            List<User> users = userRepository.findAll();
            
            for (User user : users) {
                try {
                    int streakCount = calculateWorkoutStreak(user.getUserId());
                    
                    // Send notification for milestone streaks (3, 5, 7, 10, 14, 21, 30, etc.)
                    if (isStreakMilestone(streakCount)) {
                        int nextMilestone = getNextMilestone(streakCount);
                        notificationService.createStreakNotification(user.getUserId(), streakCount, nextMilestone);
                        logger.debug("Sent streak notification to user {} for {} day streak", 
                                user.getUserId(), streakCount);
                    }
                } catch (Exception e) {
                    logger.error("Error checking streak for user {}: {}", user.getUserId(), e.getMessage());
                }
            }
        } catch (Exception e) {
            logger.error("Error in streak check job: {}", e.getMessage());
        }
    }

    /**
     * UC-15.3: Check for goal progress milestones daily at 9 AM
     */
    @Scheduled(cron = "0 0 9 * * *")
    @Transactional(readOnly = true)
    public void checkGoalProgress() {
        if (!schedulerEnabled) {
            return;
        }

        logger.info("Running goal progress check...");

        try {
            List<User> users = userRepository.findAll();
            
            for (User user : users) {
                try {
                    if (user.getPrimaryGoal() != null) {
                        int progressPercent = calculateGoalProgress(user);
                        
                        // Check for milestones (25%, 50%, 75%, 100%)
                        if (isProgressMilestone(progressPercent)) {
                            notificationService.createGoalProgressNotification(
                                    user.getUserId(),
                                    user.getPrimaryGoal().getGoalName(),
                                    progressPercent,
                                    user.getPrimaryGoal().getGoalId());
                            logger.debug("Sent goal progress notification to user {} for {}%", 
                                    user.getUserId(), progressPercent);
                        }
                    }
                } catch (Exception e) {
                    logger.error("Error checking goal progress for user {}: {}", user.getUserId(), e.getMessage());
                }
            }
        } catch (Exception e) {
            logger.error("Error in goal progress check job: {}", e.getMessage());
        }
    }

    /**
     * UC-15.1: Send daily workout reminders at 7 AM for today's scheduled sessions
     */
    @Scheduled(cron = "0 0 7 * * *")
    @Transactional(readOnly = true)
    public void sendDailyWorkoutReminders() {
        if (!schedulerEnabled) {
            return;
        }

        logger.info("Running daily workout reminder check...");

        try {
            LocalDate today = LocalDate.now();
            List<WorkoutSession> todaySessions = workoutSessionRepository.findScheduledSessionsByDate(today);

            for (WorkoutSession session : todaySessions) {
                try {
                    if (session.getIsRestDay() || session.getWorkoutPlan() == null || 
                            session.getWorkoutPlan().getUser() == null) {
                        continue;
                    }

                    Long userId = session.getWorkoutPlan().getUser().getUserId();
                    notificationService.createWorkoutReminder(
                            userId, session.getSessionName(), session.getSessionId());
                    logger.debug("Sent workout reminder to user {} for session {}",
                            userId, session.getSessionName());
                } catch (Exception e) {
                    logger.error("Error sending workout reminder for session {}: {}",
                            session.getSessionId(), e.getMessage());
                }
            }

            logger.info("Daily workout reminders completed. Sent for {} sessions.", todaySessions.size());
        } catch (Exception e) {
            logger.error("Error in daily workout reminder job: {}", e.getMessage());
        }
    }

    // ============= Helper Methods =============

    private int calculateWorkoutStreak(Long userId) {
        int streak = 0;
        LocalDate checkDate = LocalDate.now().minusDays(1); // Start from yesterday
        
        while (true) {
            Instant startOfDay = checkDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
            Instant endOfDay = checkDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
            
            long workoutsOnDay = workoutProgressRepository.countByUserUserIdAndWorkoutDateBetween(
                    userId, startOfDay, endOfDay);
            
            if (workoutsOnDay > 0) {
                streak++;
                checkDate = checkDate.minusDays(1);
            } else {
                break;
            }
            
            // Limit check to last 365 days
            if (streak >= 365) {
                break;
            }
        }
        
        return streak;
    }

    private boolean isStreakMilestone(int streakCount) {
        return streakCount == 3 || streakCount == 5 || streakCount == 7 || 
               streakCount == 10 || streakCount == 14 || streakCount == 21 || 
               streakCount == 30 || streakCount == 60 || streakCount == 90 ||
               streakCount == 100 || streakCount == 365;
    }

    private int getNextMilestone(int currentStreak) {
        int[] milestones = {3, 5, 7, 10, 14, 21, 30, 60, 90, 100, 365};
        for (int milestone : milestones) {
            if (milestone > currentStreak) {
                return milestone;
            }
        }
        return 0;
    }

    private int calculateGoalProgress(User user) {
        // This is a simplified calculation - in production, this would be more sophisticated
        // based on the specific goal type (weight loss, muscle gain, etc.)
        
        if (user.getTargetWeightKg() == null || user.getCurrentWeightKg() == null) {
            return 0;
        }
        
        float startWeight = user.getCurrentWeightKg();
        float targetWeight = user.getTargetWeightKg();
        float currentWeight = user.getCurrentWeightKg(); // Would come from latest measurement
        
        if (Math.abs(startWeight - targetWeight) < 0.1f) {
            return 100;
        }
        
        float progress = (startWeight - currentWeight) / (startWeight - targetWeight) * 100;
        return Math.max(0, Math.min(100, Math.round(progress)));
    }

    private boolean isProgressMilestone(int progressPercent) {
        return progressPercent == 25 || progressPercent == 50 || 
               progressPercent == 75 || progressPercent == 100;
    }
}
