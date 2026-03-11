package com.dev.backend.service;

import com.dev.backend.model.dto.request.RegisterDeviceTokenRequest;
import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.enums.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * Service interface for notification operations (UC-15)
 */
public interface NotificationService {

    // ============= User Notification Retrieval =============

    /**
     * Get all notifications for a user (paginated)
     */
    Page<NotificationResponse> getUserNotifications(Long userId, Pageable pageable);

    /**
     * Get unread notifications for a user
     */
    List<NotificationResponse> getUnreadNotifications(Long userId);

    /**
     * Get count of unread notifications
     */
    long getUnreadCount(Long userId);

    /**
     * Get notifications by type for a user
     */
    Page<NotificationResponse> getNotificationsByType(Long userId, NotificationType type, Pageable pageable);

    // ============= Notification Status Management =============

    /**
     * Mark a notification as read
     */
    void markAsRead(Long notificationId, Long userId);

    /**
     * Mark all notifications as read for a user
     */
    int markAllAsRead(Long userId);

    /**
     * Mark a notification as acted upon
     */
    void markAsActedUpon(Long notificationId, Long userId);

    // ============= Device Token Management (FCM) =============

    /**
     * Register a device token for push notifications
     */
    void registerDeviceToken(Long userId, RegisterDeviceTokenRequest request);

    /**
     * Remove a device token (logout)
     */
    void removeDeviceToken(String token);

    // ============= Notification Creation (UC-15.1 - 15.4) =============

    /**
     * UC-15.1: Create workout reminder notification
     */
    void createWorkoutReminder(Long userId, String sessionName, Long sessionId);

    /**
     * UC-15.2: Create streak celebration notification
     */
    void createStreakNotification(Long userId, int streakCount, int nextMilestone);

    /**
     * UC-15.3: Create goal progress notification
     */
    void createGoalProgressNotification(Long userId, String goalName, int progressPercent, Long goalId);

    /**
     * UC-15.4: Create missed workout notification
     */
    void createMissedWorkoutNotification(Long userId, String sessionName, Long sessionId, String missedDate);

    // ============= Push Notification Sending =============

    /**
     * Send push notification to a user's devices
     */
    void sendPushNotification(Long userId, String title, String body, String data);
}
