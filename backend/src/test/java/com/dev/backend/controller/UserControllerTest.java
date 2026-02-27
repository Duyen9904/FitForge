package com.dev.backend.controller;

import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    private UserProfileResponse mockProfile;
    private GoalResponse mockGoal;

    @BeforeEach
    void setUp() {
        mockGoal = GoalResponse.builder()
                .goalId(1L)
                .goalName("Fat Loss")
                .description("Reduce body fat")
                .build();

        mockProfile = UserProfileResponse.builder()
                .userId(1L)
                .username("testuser")
                .email("test@example.com")
                .primaryGoal(mockGoal)
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/users/me")
    class GetCurrentUserProfileTests {

        @Test
        @DisplayName("Should return current user profile")
        void getCurrentUserProfile_Success() throws Exception {
            when(userService.getCurrentUserProfile(anyLong())).thenReturn(mockProfile);

            mockMvc.perform(get("/api/v1/users/me")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(userService, times(1)).getCurrentUserProfile(1L);
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getCurrentUserProfile_NoAuth_ReturnsUnauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/users/me"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/users/me/primary-goal")
    class SetPrimaryGoalTests {

        @Test
        @DisplayName("Should set primary fitness goal successfully")
        void setPrimaryGoal_Success() throws Exception {
            SetPrimaryGoalRequest request = SetPrimaryGoalRequest.builder()
                    .goalId(1L)
                    .build();

            when(userService.setPrimaryGoal(anyLong(), any(SetPrimaryGoalRequest.class)))
                    .thenReturn(mockProfile);

            mockMvc.perform(put("/api/v1/users/me/primary-goal")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk());

            verify(userService, times(1)).setPrimaryGoal(eq(1L), any(SetPrimaryGoalRequest.class));
        }

        @Test
        @DisplayName("Should return 400 when goalId is null")
        void setPrimaryGoal_NullGoalId_ReturnsBadRequest() throws Exception {
            SetPrimaryGoalRequest invalidRequest = new SetPrimaryGoalRequest();

            mockMvc.perform(put("/api/v1/users/me/primary-goal")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(userService, never()).setPrimaryGoal(anyLong(), any());
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void setPrimaryGoal_NoAuth_ReturnsUnauthorized() throws Exception {
            SetPrimaryGoalRequest request = SetPrimaryGoalRequest.builder()
                    .goalId(1L)
                    .build();

            mockMvc.perform(put("/api/v1/users/me/primary-goal")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isUnauthorized());
        }
    }
}
