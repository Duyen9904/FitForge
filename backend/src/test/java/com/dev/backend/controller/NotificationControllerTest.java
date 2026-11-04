package com.dev.backend.controller;

import com.dev.backend.model.dto.request.RegisterDeviceTokenRequest;
import com.dev.backend.model.dto.response.NotificationResponse;
import com.dev.backend.model.enums.NotificationType;
import com.dev.backend.service.NotificationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NotificationController.class)
class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private NotificationService notificationService;

    private NotificationResponse mockNotification;

    @BeforeEach
    void setUp() {
        mockNotification = NotificationResponse.builder()
                .notificationId(1L)
                .notificationType(NotificationType.WORKOUT_REMINDER)
                .title("Time for your workout!")
                .message("Your Push Day workout is ready")
                .isRead(false)
                .isActedUpon(false)
                .createdAt(Instant.now())
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/notifications")
    class GetNotificationsTests {

        @Test
        @DisplayName("Should return paginated notifications")
        void getNotifications_Success() throws Exception {
            Page<NotificationResponse> page = new PageImpl<>(
                    List.of(mockNotification), PageRequest.of(0, 20), 1);
            
            when(notificationService.getUserNotifications(anyLong(), any(), any()))
                    .thenReturn(page);

            mockMvc.perform(get("/api/v1/notifications")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk());

            verify(notificationService, times(1)).getUserNotifications(eq(1L), isNull(), any());
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getNotifications_Unauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/notifications"))
                    .andExpect(status().isUnauthorized());
        }
    }



    @Nested
    @DisplayName("GET /api/v1/notifications/unread/count")
    class GetUnreadCountTests {

        @Test
        @DisplayName("Should return unread count")
        void getUnreadCount_Success() throws Exception {
            when(notificationService.getUnreadCount(1L)).thenReturn(5L);

            mockMvc.perform(get("/api/v1/notifications/unread/count")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk());

            verify(notificationService, times(1)).getUnreadCount(1L);
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/notifications/{id}/read")
    class MarkAsReadTests {

        @Test
        @DisplayName("Should mark notification as read")
        void markAsRead_Success() throws Exception {
            doNothing().when(notificationService).markAsRead(1L, 1L);

            mockMvc.perform(put("/api/v1/notifications/1/read")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf()))
                    .andExpect(status().isOk());

            verify(notificationService, times(1)).markAsRead(1L, 1L);
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/notifications/read-all")
    class MarkAllAsReadTests {

        @Test
        @DisplayName("Should mark all notifications as read")
        void markAllAsRead_Success() throws Exception {
            when(notificationService.markAllAsRead(1L)).thenReturn(10);

            mockMvc.perform(put("/api/v1/notifications/read-all")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf()))
                    .andExpect(status().isOk());

            verify(notificationService, times(1)).markAllAsRead(1L);
        }
    }

    @Nested
    @DisplayName("POST /api/v1/notifications/devices")
    class RegisterDeviceTokenTests {

        @Test
        @DisplayName("Should register device token")
        void registerDevice_Success() throws Exception {
            RegisterDeviceTokenRequest request = RegisterDeviceTokenRequest.builder()
                    .deviceToken("fcm-token-123")
                    .deviceType("ANDROID")
                    .build();

            doNothing().when(notificationService).registerDeviceToken(anyLong(), any());

            mockMvc.perform(post("/api/v1/notifications/devices")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isCreated());

            verify(notificationService, times(1)).registerDeviceToken(eq(1L), any());
        }

        @Test
        @DisplayName("Should return 400 for invalid request")
        void registerDevice_InvalidRequest() throws Exception {
            RegisterDeviceTokenRequest request = RegisterDeviceTokenRequest.builder()
                    .deviceToken("") // blank token
                    .build();

            mockMvc.perform(post("/api/v1/notifications/devices")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/notifications/devices")
    class RemoveDeviceTokenTests {

        @Test
        @DisplayName("Should remove device token")
        void removeDevice_Success() throws Exception {
            doNothing().when(notificationService).removeDeviceToken(anyString());

            mockMvc.perform(delete("/api/v1/notifications/devices")
                            .param("token", "fcm-token-123")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf()))
                    .andExpect(status().isNoContent());

            verify(notificationService, times(1)).removeDeviceToken("fcm-token-123");
        }
    }
}
