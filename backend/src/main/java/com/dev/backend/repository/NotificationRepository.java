package com.dev.backend.repository;

import com.dev.backend.model.entity.Notification;
import com.dev.backend.model.enums.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

/**
 * Repository for user notifications (UC-15)
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /**
     * Find all notifications for a user ordered by creation date
     */
    Page<Notification> findByUserUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * Find unread notifications for a user
     */
    List<Notification> findByUserUserIdAndIsReadFalseOrderByCreatedAtDesc(Long userId);

    /**
     * Count unread notifications for a user
     */
    long countByUserUserIdAndIsReadFalse(Long userId);

    /**
     * Find notifications by type for a user
     */
    Page<Notification> findByUserUserIdAndNotificationTypeOrderByCreatedAtDesc(
            Long userId, NotificationType notificationType, Pageable pageable);

    /**
     * Mark all notifications as read for a user
     */
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.user.userId = :userId AND n.isRead = false")
    int markAllAsReadByUserId(@Param("userId") Long userId);

    /**
     * Find notifications scheduled for a specific time range (for scheduled reminders)
     */
    @Query("SELECT n FROM Notification n WHERE n.scheduledFor BETWEEN :startTime AND :endTime AND n.isRead = false")
    List<Notification> findScheduledNotifications(
            @Param("startTime") Instant startTime,
            @Param("endTime") Instant endTime);

    /**
     * Check if a similar notification already exists to prevent duplicates
     */
    boolean existsByUserUserIdAndNotificationTypeAndReferenceIdAndCreatedAtAfter(
            Long userId, NotificationType notificationType, Long referenceId, Instant afterTime);

    /**
     * Delete old read notifications (for cleanup)
     */
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.isRead = true AND n.createdAt < :olderThan")
    int deleteOldReadNotifications(@Param("olderThan") Instant olderThan);
}
