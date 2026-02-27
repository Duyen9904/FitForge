package com.dev.backend.model.entity;

import com.dev.backend.model.enums.NotificationType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

/**
 * Entity for storing user notifications (UC-15)
 */
@Entity
@Table(
    name = "notification",
    indexes = {
        @Index(name = "idx_notification_user", columnList = "user_id"),
        @Index(name = "idx_notification_user_read", columnList = "user_id, is_read"),
        @Index(name = "idx_notification_created", columnList = "created_at")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class Notification extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long notificationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private NotificationType notificationType;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, length = 1000)
    private String message;

    /**
     * JSON data for additional context (e.g., session details, streak count, progress percentage)
     */
    @Column(columnDefinition = "TEXT")
    private String data;

    @Column(nullable = false)
    private Boolean isRead = false;

    @Column(nullable = false)
    private Boolean isActedUpon = false;

    @Column(nullable = false)
    private Instant createdAt;

    /**
     * Optional scheduled time for the notification (for workout reminders)
     */
    private Instant scheduledFor;

    /**
     * Reference ID (e.g., workoutSessionId, achievementId, goalId)
     */
    private Long referenceId;

    /**
     * Reference type (e.g., "WORKOUT_SESSION", "ACHIEVEMENT", "GOAL")
     */
    @Column(length = 50)
    private String referenceType;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
