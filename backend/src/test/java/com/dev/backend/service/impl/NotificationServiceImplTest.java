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
import com.google.firebase.messaging.FirebaseMessaging;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceImplTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private DeviceTokenRepository deviceTokenRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private NotificationMapper notificationMapper;

    @Mock
    private FirebaseMessaging firebaseMessaging;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    private User mockUser;
    private Notification mockNotification;
    private NotificationResponse mockNotificationResponse;
    private DeviceToken mockDeviceToken;

    @BeforeEach
    void setUp() {
        mockUser = new User();
        mockUser.setUserId(1L);
        mockUser.setEmail("test@example.com");
        mockUser.setUsername("testuser");

        mockNotification = new Notification();
        mockNotification.setNotificationId(1L);
        mockNotification.setUser(mockUser);
        mockNotification.setNotificationType(NotificationType.WORKOUT_REMINDER);
        mockNotification.setTitle("Time for your workout!");
        mockNotification.setMessage("Your Push Day workout is ready");
        mockNotification.setIsRead(false);
        mockNotification.setIsActedUpon(false);
        mockNotification.setCreatedAt(Instant.now());

        mockNotificationResponse = NotificationResponse.builder()
                .notificationId(1L)
                .notificationType(NotificationType.WORKOUT_REMINDER)
                .title("Time for your workout!")
                .message("Your Push Day workout is ready")
                .isRead(false)
                .isActedUpon(false)
                .createdAt(Instant.now())
                .build();

        mockDeviceToken = new DeviceToken();
        mockDeviceToken.setDeviceTokenId(1L);
        mockDeviceToken.setUser(mockUser);
        mockDeviceToken.setToken("test-fcm-token");
        mockDeviceToken.setDeviceType("ANDROID");
        mockDeviceToken.setIsActive(true);
    }

    @Nested
    @DisplayName("getUserNotifications")
    class GetUserNotificationsTests {

        @Test
        @DisplayName("Should return paginated notifications for user")
        void getUserNotifications_Success() {
            // Given
            Pageable pageable = PageRequest.of(0, 10);
            Page<Notification> notificationPage = new PageImpl<>(List.of(mockNotification), pageable, 1);

            when(notificationRepository.findByUserUserIdOrderByCreatedAtDesc(1L, pageable))
                    .thenReturn(notificationPage);
            when(notificationMapper.toResponse(mockNotification)).thenReturn(mockNotificationResponse);

            // When
            Page<NotificationResponse> result = notificationService.getUserNotifications(1L, pageable);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getContent()).hasSize(1);
            assertThat(result.getContent().get(0).getTitle()).isEqualTo("Time for your workout!");
            verify(notificationRepository, times(1)).findByUserUserIdOrderByCreatedAtDesc(1L, pageable);
        }

        @Test
        @DisplayName("Should return empty page when user has no notifications")
        void getUserNotifications_Empty() {
            // Given
            Pageable pageable = PageRequest.of(0, 10);
            Page<Notification> emptyPage = Page.empty(pageable);

            when(notificationRepository.findByUserUserIdOrderByCreatedAtDesc(1L, pageable))
                    .thenReturn(emptyPage);

            // When
            Page<NotificationResponse> result = notificationService.getUserNotifications(1L, pageable);

            // Then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getUnreadNotifications")
    class GetUnreadNotificationsTests {

        @Test
        @DisplayName("Should return unread notifications only")
        void getUnreadNotifications_Success() {
            // Given
            when(notificationRepository.findByUserUserIdAndIsReadFalseOrderByCreatedAtDesc(1L))
                    .thenReturn(List.of(mockNotification));
            when(notificationMapper.toResponseList(List.of(mockNotification)))
                    .thenReturn(List.of(mockNotificationResponse));

            // When
            List<NotificationResponse> result = notificationService.getUnreadNotifications(1L);

            // Then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).getIsRead()).isFalse();
        }
    }

    @Nested
    @DisplayName("getUnreadCount")
    class GetUnreadCountTests {

        @Test
        @DisplayName("Should return correct unread count")
        void getUnreadCount_Success() {
            // Given
            when(notificationRepository.countByUserUserIdAndIsReadFalse(1L)).thenReturn(5L);

            // When
            long count = notificationService.getUnreadCount(1L);

            // Then
            assertThat(count).isEqualTo(5L);
        }
    }

    @Nested
    @DisplayName("markAsRead")
    class MarkAsReadTests {

        @Test
        @DisplayName("Should mark notification as read")
        void markAsRead_Success() {
            // Given
            when(notificationRepository.findById(1L)).thenReturn(Optional.of(mockNotification));

            // When
            notificationService.markAsRead(1L, 1L);

            // Then
            assertThat(mockNotification.getIsRead()).isTrue();
            verify(notificationRepository, times(1)).save(mockNotification);
        }

        @Test
        @DisplayName("Should throw exception when notification not found")
        void markAsRead_NotFound() {
            // Given
            when(notificationRepository.findById(anyLong())).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> notificationService.markAsRead(999L, 1L))
                    .isInstanceOf(ResourceNotFoundException.class);
        }

        @Test
        @DisplayName("Should throw exception when notification belongs to different user")
        void markAsRead_WrongUser() {
            // Given
            when(notificationRepository.findById(1L)).thenReturn(Optional.of(mockNotification));

            // When/Then (user 2 trying to mark user 1's notification)
            assertThatThrownBy(() -> notificationService.markAsRead(1L, 2L))
                    .isInstanceOf(ResourceNotFoundException.class);
        }
    }

    @Nested
    @DisplayName("markAllAsRead")
    class MarkAllAsReadTests {

        @Test
        @DisplayName("Should mark all notifications as read")
        void markAllAsRead_Success() {
            // Given
            when(notificationRepository.markAllAsReadByUserId(1L)).thenReturn(10);

            // When
            int count = notificationService.markAllAsRead(1L);

            // Then
            assertThat(count).isEqualTo(10);
            verify(notificationRepository, times(1)).markAllAsReadByUserId(1L);
        }
    }

    @Nested
    @DisplayName("registerDeviceToken")
    class RegisterDeviceTokenTests {

        @Test
        @DisplayName("Should register new device token")
        void registerDeviceToken_NewToken() {
            // Given
            RegisterDeviceTokenRequest request = RegisterDeviceTokenRequest.builder()
                    .deviceToken("new-fcm-token")
                    .deviceType("ANDROID")
                    .deviceName("Pixel 7")
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(deviceTokenRepository.findByToken("new-fcm-token")).thenReturn(Optional.empty());

            // When
            notificationService.registerDeviceToken(1L, request);

            // Then
            ArgumentCaptor<DeviceToken> tokenCaptor = ArgumentCaptor.forClass(DeviceToken.class);
            verify(deviceTokenRepository, times(1)).save(tokenCaptor.capture());

            DeviceToken savedToken = tokenCaptor.getValue();
            assertThat(savedToken.getToken()).isEqualTo("new-fcm-token");
            assertThat(savedToken.getDeviceType()).isEqualTo("ANDROID");
            assertThat(savedToken.getDeviceName()).isEqualTo("Pixel 7");
        }

        @Test
        @DisplayName("Should update existing device token")
        void registerDeviceToken_ExistingToken() {
            // Given
            RegisterDeviceTokenRequest request = RegisterDeviceTokenRequest.builder()
                    .deviceToken("test-fcm-token")
                    .deviceType("IOS")
                    .deviceName("iPhone 15")
                    .build();

            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(deviceTokenRepository.findByToken("test-fcm-token")).thenReturn(Optional.of(mockDeviceToken));

            // When
            notificationService.registerDeviceToken(1L, request);

            // Then
            verify(deviceTokenRepository, times(1)).save(mockDeviceToken);
            assertThat(mockDeviceToken.getDeviceType()).isEqualTo("IOS");
            assertThat(mockDeviceToken.getDeviceName()).isEqualTo("iPhone 15");
        }
    }

    @Nested
    @DisplayName("createWorkoutReminder")
    class CreateWorkoutReminderTests {

        @Test
        @DisplayName("Should create workout reminder notification")
        void createWorkoutReminder_Success() {
            // Given
            when(notificationRepository.existsByUserUserIdAndNotificationTypeAndReferenceIdAndCreatedAtAfter(
                    anyLong(), any(), anyLong(), any())).thenReturn(false);
            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(deviceTokenRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(List.of());

            // When
            notificationService.createWorkoutReminder(1L, "Push Day", 100L);

            // Then
            ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
            verify(notificationRepository, times(1)).save(notificationCaptor.capture());

            Notification savedNotification = notificationCaptor.getValue();
            assertThat(savedNotification.getNotificationType()).isEqualTo(NotificationType.WORKOUT_REMINDER);
            assertThat(savedNotification.getTitle()).contains("workout");
            assertThat(savedNotification.getReferenceId()).isEqualTo(100L);
        }

        @Test
        @DisplayName("Should not create duplicate reminder within an hour")
        void createWorkoutReminder_SkipDuplicate() {
            // Given - duplicate exists
            when(notificationRepository.existsByUserUserIdAndNotificationTypeAndReferenceIdAndCreatedAtAfter(
                    anyLong(), any(), anyLong(), any())).thenReturn(true);

            // When
            notificationService.createWorkoutReminder(1L, "Push Day", 100L);

            // Then - should not save
            verify(notificationRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("createStreakNotification")
    class CreateStreakNotificationTests {

        @Test
        @DisplayName("Should create streak celebration notification")
        void createStreakNotification_Success() {
            // Given
            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(deviceTokenRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(List.of());

            // When
            notificationService.createStreakNotification(1L, 7, 10);

            // Then
            ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
            verify(notificationRepository, times(1)).save(notificationCaptor.capture());

            Notification savedNotification = notificationCaptor.getValue();
            assertThat(savedNotification.getNotificationType()).isEqualTo(NotificationType.STREAK);
            assertThat(savedNotification.getTitle()).contains("7-day");
        }
    }

    @Nested
    @DisplayName("createGoalProgressNotification")
    class CreateGoalProgressNotificationTests {

        @Test
        @DisplayName("Should create goal milestone notification")
        void createGoalProgressNotification_Success() {
            // Given
            when(notificationRepository.existsByUserUserIdAndNotificationTypeAndReferenceIdAndCreatedAtAfter(
                    anyLong(), any(), anyLong(), any())).thenReturn(false);
            when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
            when(deviceTokenRepository.findByUserUserIdAndIsActiveTrue(1L)).thenReturn(List.of());

            // When
            notificationService.createGoalProgressNotification(1L, "Fat Loss", 50, 10L);

            // Then
            ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
            verify(notificationRepository, times(1)).save(notificationCaptor.capture());

            Notification savedNotification = notificationCaptor.getValue();
            assertThat(savedNotification.getNotificationType()).isEqualTo(NotificationType.GOAL_PROGRESS);
            assertThat(savedNotification.getMessage()).contains("50%");
        }
    }
}
