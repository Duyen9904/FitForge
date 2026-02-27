package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * DTO for notification data in API responses (UC-15)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private Long notificationId;
    private NotificationType notificationType;
    private String title;
    private String message;
    private String data;
    private Boolean isRead;
    private Boolean isActedUpon;
    private Instant createdAt;
    private Instant scheduledFor;
    private Long referenceId;
    private String referenceType;
}
