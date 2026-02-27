package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.entity.Notification;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Mapper for Notification entity to DTO conversions (UC-15)
 */
@Component
public class NotificationMapper {

    /**
     * Convert Notification entity to NotificationResponse DTO
     */
    public NotificationResponse toResponse(Notification notification) {
        if (notification == null) {
            return null;
        }

        return NotificationResponse.builder()
                .notificationId(notification.getNotificationId())
                .notificationType(notification.getNotificationType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .data(notification.getData())
                .isRead(notification.getIsRead())
                .isActedUpon(notification.getIsActedUpon())
                .createdAt(notification.getCreatedAt())
                .scheduledFor(notification.getScheduledFor())
                .referenceId(notification.getReferenceId())
                .referenceType(notification.getReferenceType())
                .build();
    }

    /**
     * Convert list of Notification entities to list of NotificationResponse DTOs
     */
    public List<NotificationResponse> toResponseList(List<Notification> notifications) {
        return notifications.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
}
