package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.NotificationMapper;
import com.dev.backend.model.dto.request.RegisterDeviceTokenRequest;
import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.entity.DeviceToken;
import com.dev.backend.model.entity.Notification;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.enums.NotificationType;
import com.dev.backend.repository.DeviceTokenRepository;
import com.dev.backend.repository.NotificationRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.NotificationService;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Implementation of NotificationService (UC-15)
 */
@Service
@Transactional
public class NotificationServiceImpl implements NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationServiceImpl.class);

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final UserRepository userRepository;
    private final NotificationMapper notificationMapper;
    private final FirebaseMessaging firebaseMessaging;

    @Autowired
    public NotificationServiceImpl(
            NotificationRepository notificationRepository,
            DeviceTokenRepository deviceTokenRepository,
            UserRepository userRepository,
            NotificationMapper notificationMapper,
            @Autowired(required = false) FirebaseMessaging firebaseMessaging) {
        this.notificationRepository = notificationRepository;
        this.deviceTokenRepository = deviceTokenRepository;
        this.userRepository = userRepository;
        this.notificationMapper = notificationMapper;
        this.firebaseMessaging = firebaseMessaging;
    }

    // ============= User Notification Retrieval =============

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getUserNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByUserUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(notificationMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationResponse> getUnreadNotifications(Long userId) {
        List<Notification> notifications = notificationRepository
                .findByUserUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
        return notificationMapper.toResponseList(notifications);
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserUserIdAndIsReadFalse(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getNotificationsByType(Long userId, NotificationType type, Pageable pageable) {
        return notificationRepository
                .findByUserUserIdAndNotificationTypeOrderByCreatedAtDesc(userId, type, pageable)
                .map(notificationMapper::toResponse);
    }

    // ============= Notification Status Management =============

    @Override
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification", "id", notificationId));
        
        if (!notification.getUser().getUserId().equals(userId)) {
            throw new ResourceNotFoundException("Notification", "id", notificationId);
        }
        
        notification.setIsRead(true);
        notificationRepository.save(notification);
    }

    @Override
    public int markAllAsRead(Long userId) {
        return notificationRepository.markAllAsReadByUserId(userId);
    }

    @Override
    public void markAsActedUpon(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification", "id", notificationId));
        
        if (!notification.getUser().getUserId().equals(userId)) {
            throw new ResourceNotFoundException("Notification", "id", notificationId);
        }
        
        notification.setIsActedUpon(true);
        notification.setIsRead(true);
        notificationRepository.save(notification);
    }

    // ============= Device Token Management (FCM) =============

    @Override
    public void registerDeviceToken(Long userId, RegisterDeviceTokenRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        // Check if token already exists
        DeviceToken existingToken = deviceTokenRepository.findByToken(request.getDeviceToken())
                .orElse(null);

        if (existingToken != null) {
            // Update existing token
            existingToken.setUser(user);
            existingToken.setDeviceType(request.getDeviceType());
            existingToken.setDeviceName(request.getDeviceName());
            existingToken.setIsActive(true);
            existingToken.setLastUsedAt(Instant.now());
            deviceTokenRepository.save(existingToken);
        } else {
            // Create new token
            DeviceToken newToken = new DeviceToken();
            newToken.setUser(user);
            newToken.setToken(request.getDeviceToken());
            newToken.setDeviceType(request.getDeviceType());
            newToken.setDeviceName(request.getDeviceName());
            newToken.setIsActive(true);
            newToken.setLastUsedAt(Instant.now());
            deviceTokenRepository.save(newToken);
        }
    }

    @Override
    public void removeDeviceToken(String token) {
        deviceTokenRepository.deactivateToken(token);
    }

    // ============= Notification Creation (UC-15.1 - 15.4) =============

    @Override
    public void createWorkoutReminder(Long userId, String sessionName, Long sessionId) {
        // Check for duplicate within last hour
        if (isDuplicateNotification(userId, NotificationType.WORKOUT_REMINDER, sessionId)) {
            return;
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String title = "🏋️ Time for your workout!";
        String message = String.format("Your %s workout is ready. Let's crush it!", sessionName);
        String data = String.format("{\"sessionId\":%d,\"sessionName\":\"%s\"}", sessionId, sessionName);

        Notification notification = createNotification(user, NotificationType.WORKOUT_REMINDER, 
                title, message, data, sessionId, "WORKOUT_SESSION");

        notificationRepository.save(notification);

        // Send push notification
        sendPushNotification(userId, title, message, data);
    }

    @Override
    public void createStreakNotification(Long userId, int streakCount, int nextMilestone) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String title = String.format("🔥 %d-day workout streak!", streakCount);
        String message;
        if (nextMilestone > 0) {
            message = String.format("Keep it up! Only %d more days until your next milestone!", nextMilestone - streakCount);
        } else {
            message = "You're on fire! Keep the momentum going!";
        }
        String data = String.format("{\"streakCount\":%d,\"nextMilestone\":%d}", streakCount, nextMilestone);

        Notification notification = createNotification(user, NotificationType.STREAK, 
                title, message, data, null, null);

        notificationRepository.save(notification);

        // Send push notification
        sendPushNotification(userId, title, message, data);
    }

    @Override
    public void createGoalProgressNotification(Long userId, String goalName, int progressPercent, Long goalId) {
        // Check for duplicate within last 24 hours
        if (isDuplicateNotification(userId, NotificationType.GOAL_PROGRESS, goalId)) {
            return;
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String title = getMilestoneTitle(progressPercent);
        String message = String.format("You've reached %d%% of your %s goal!", progressPercent, goalName);
        String data = String.format("{\"goalId\":%d,\"goalName\":\"%s\",\"progressPercent\":%d}", 
                goalId, goalName, progressPercent);

        Notification notification = createNotification(user, NotificationType.GOAL_PROGRESS, 
                title, message, data, goalId, "GOAL");

        notificationRepository.save(notification);

        // Send push notification
        sendPushNotification(userId, title, message, data);
    }

    @Override
    public void createMissedWorkoutNotification(Long userId, String sessionName, Long sessionId, String missedDate) {
        // Check for duplicate within last hour
        if (isDuplicateNotification(userId, NotificationType.MISSED_WORKOUT, sessionId)) {
            return;
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String title = "⚠️ Missed Workout";
        String message = String.format("You missed your %s workout on %s. Don't worry — get back on track today!", sessionName, missedDate);
        String data = String.format("{\"sessionId\":%d,\"sessionName\":\"%s\",\"missedDate\":\"%s\"}", sessionId, sessionName, missedDate);

        Notification notification = createNotification(user, NotificationType.MISSED_WORKOUT,
                title, message, data, sessionId, "WORKOUT_SESSION");

        notificationRepository.save(notification);

        // Send push notification
        sendPushNotification(userId, title, message, data);
    }

    // ============= Push Notification Sending =============

    @Override
    public void sendPushNotification(Long userId, String title, String body, String data) {
        if (firebaseMessaging == null) {
            logger.debug("Firebase is not configured. Skipping push notification.");
            return;
        }

        List<DeviceToken> deviceTokens = deviceTokenRepository.findByUserUserIdAndIsActiveTrue(userId);

        for (DeviceToken deviceToken : deviceTokens) {
            try {
                Message message = Message.builder()
                        .setToken(deviceToken.getToken())
                        .setNotification(com.google.firebase.messaging.Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putData("payload", data != null ? data : "{}")
                        .build();

                String response = firebaseMessaging.send(message);
                logger.debug("Successfully sent push notification: {}", response);

                // Update last used time
                deviceTokenRepository.updateLastUsedAt(deviceToken.getToken(), Instant.now());
            } catch (FirebaseMessagingException e) {
                logger.error("Failed to send push notification to token {}: {}", 
                        deviceToken.getToken(), e.getMessage());
                
                // Deactivate invalid tokens
                if (isInvalidTokenError(e)) {
                    deviceTokenRepository.deactivateToken(deviceToken.getToken());
                    logger.info("Deactivated invalid device token: {}", deviceToken.getToken());
                }
            }
        }
    }

    // ============= Private Helper Methods =============

    private Notification createNotification(User user, NotificationType type, 
            String title, String message, String data, Long referenceId, String referenceType) {
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setNotificationType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setData(data);
        notification.setReferenceId(referenceId);
        notification.setReferenceType(referenceType);
        notification.setIsRead(false);
        notification.setIsActedUpon(false);
        return notification;
    }

    private boolean isDuplicateNotification(Long userId, NotificationType type, Long referenceId) {
        if (referenceId == null) {
            return false;
        }
        Instant oneHourAgo = Instant.now().minus(1, ChronoUnit.HOURS);
        return notificationRepository.existsByUserUserIdAndNotificationTypeAndReferenceIdAndCreatedAtAfter(
                userId, type, referenceId, oneHourAgo);
    }

    private String getMilestoneTitle(int progressPercent) {
        if (progressPercent >= 100) {
            return "🎉 Goal Achieved!";
        } else if (progressPercent >= 75) {
            return "🌟 75% - Almost there!";
        } else if (progressPercent >= 50) {
            return "💪 50% - Halfway there!";
        } else if (progressPercent >= 25) {
            return "🚀 25% - Great start!";
        } else {
            return "📈 Progress Update";
        }
    }

    private boolean isInvalidTokenError(FirebaseMessagingException e) {
        String errorCode = e.getMessagingErrorCode() != null ? 
                e.getMessagingErrorCode().name() : "";
        return errorCode.contains("UNREGISTERED") || 
               errorCode.contains("INVALID_ARGUMENT");
    }
}
