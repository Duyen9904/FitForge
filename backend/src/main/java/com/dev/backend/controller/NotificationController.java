package com.dev.backend.controller;

import com.dev.backend.model.dto.request.RegisterDeviceTokenRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.enums.NotificationType;
import com.dev.backend.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller for user notification endpoints (UC-15)
 */
@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "Notifications", description = "User notification management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @Operation(summary = "Get all notifications", description = "UC-15: Get paginated list of user notifications")
    @PreAuthorize("isAuthenticated()")
    @GetMapping
    public ApiResponse<Page<NotificationResponse>> getNotifications(
            @AuthenticationPrincipal Jwt jwt,
            @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<NotificationResponse> notifications = notificationService.getUserNotifications(userId, pageable);
        return ApiResponse.success(notifications);
    }

    @Operation(summary = "Get unread notifications", description = "Get all unread notifications for the user")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/unread")
    public ApiResponse<List<NotificationResponse>> getUnreadNotifications(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<NotificationResponse> notifications = notificationService.getUnreadNotifications(userId);
        return ApiResponse.success(notifications);
    }

    @Operation(summary = "Get unread count", description = "Get count of unread notifications")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/unread/count")
    public ApiResponse<Long> getUnreadCount(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        long count = notificationService.getUnreadCount(userId);
        return ApiResponse.success(count);
    }

    @Operation(summary = "Get notifications by type", description = "Filter notifications by type (WORKOUT_REMINDER, STREAK, GOAL_PROGRESS)")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/type/{type}")
    public ApiResponse<Page<NotificationResponse>> getNotificationsByType(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable NotificationType type,
            @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<NotificationResponse> notifications = notificationService.getNotificationsByType(userId, type, pageable);
        return ApiResponse.success(notifications);
    }

    @Operation(summary = "Mark notification as read", description = "Mark a specific notification as read")
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/{notificationId}/read")
    public ApiResponse<Void> markAsRead(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long notificationId) {
        Long userId = Long.parseLong(jwt.getSubject());
        notificationService.markAsRead(notificationId, userId);
        return ApiResponse.success(null, "Notification marked as read");
    }

    @Operation(summary = "Mark all notifications as read", description = "Mark all user notifications as read")
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/read-all")
    public ApiResponse<Integer> markAllAsRead(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        int count = notificationService.markAllAsRead(userId);
        return ApiResponse.success(count, count + " notifications marked as read");
    }

    @Operation(summary = "Mark notification as acted upon", description = "Mark a notification as acted upon (also marks as read)")
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/{notificationId}/acted")
    public ApiResponse<Void> markAsActedUpon(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long notificationId) {
        Long userId = Long.parseLong(jwt.getSubject());
        notificationService.markAsActedUpon(notificationId, userId);
        return ApiResponse.success(null, "Notification marked as acted upon");
    }

    @Operation(summary = "Register device for push notifications", description = "Register FCM device token for receiving push notifications")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/devices")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<Void> registerDeviceToken(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody RegisterDeviceTokenRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        notificationService.registerDeviceToken(userId, request);
        return ApiResponse.success(null, "Device registered for push notifications");
    }

    @Operation(summary = "Unregister device", description = "Remove FCM device token (e.g., on logout)")
    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/devices")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> removeDeviceToken(@RequestParam String token) {
        notificationService.removeDeviceToken(token);
        return ApiResponse.success(null, "Device unregistered from push notifications");
    }
}
