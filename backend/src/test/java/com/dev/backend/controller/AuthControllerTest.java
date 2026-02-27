package com.dev.backend.controller;

import com.dev.backend.model.dto.request.LoginRequestDto;
import com.dev.backend.model.dto.request.RefreshTokenRequest;
import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.AccountSummaryDto;
import com.dev.backend.model.dto.response.AuthResponseDto;
import com.dev.backend.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AuthController.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    private AuthResponseDto mockAuthResponse;
    private LoginRequestDto validLoginRequest;
    private RegisterRequestDto validRegisterRequest;
    private RefreshTokenRequest validRefreshTokenRequest;

    @BeforeEach
    void setUp() {
        // Setup mock auth response
        mockAuthResponse = AuthResponseDto.builder()
                .accessToken("mock-access-token")
                .refreshToken("mock-refresh-token")
                .tokenType("Bearer")
                .expiresAt(System.currentTimeMillis() + 900000) // 15 minutes
                .user(AccountSummaryDto.builder()
                        .email("test@example.com")
                        .username("testuser")
                        .build())
                .build();

        // Setup valid login request
        validLoginRequest = new LoginRequestDto();
        validLoginRequest.setEmail("test@example.com");
        validLoginRequest.setPassword("password123");

        // Setup valid register request
        validRegisterRequest = new RegisterRequestDto();
        validRegisterRequest.setUsername("testuser");
        validRegisterRequest.setEmail("test@example.com");
        validRegisterRequest.setPassword("password123");
        validRegisterRequest.setConfirmPassword("password123");

        // Setup valid refresh token request
        validRefreshTokenRequest = new RefreshTokenRequest();
        validRefreshTokenRequest.setRefreshToken("valid-refresh-token");
    }

    @Nested
    @DisplayName("POST /api/v1/auth/login")
    class LoginTests {

        @Test
        @DisplayName("Should return auth response when login is successful")
        @WithMockUser
        void login_Success() throws Exception {
            when(authService.loginWithEmailPassword(any(LoginRequestDto.class)))
                    .thenReturn(mockAuthResponse);

            mockMvc.perform(post("/api/v1/auth/login")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(validLoginRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.accessToken").value("mock-access-token"))
                    .andExpect(jsonPath("$.data.refreshToken").value("mock-refresh-token"))
                    .andExpect(jsonPath("$.data.tokenType").value("Bearer"))
                    .andExpect(jsonPath("$.message").value("Login successful"));

            verify(authService, times(1)).loginWithEmailPassword(any(LoginRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when email is blank")
        @WithMockUser
        void login_BlankEmail_ReturnsBadRequest() throws Exception {
            LoginRequestDto invalidRequest = new LoginRequestDto();
            invalidRequest.setEmail("");
            invalidRequest.setPassword("password123");

            mockMvc.perform(post("/api/v1/auth/login")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).loginWithEmailPassword(any(LoginRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when password is blank")
        @WithMockUser
        void login_BlankPassword_ReturnsBadRequest() throws Exception {
            LoginRequestDto invalidRequest = new LoginRequestDto();
            invalidRequest.setEmail("test@example.com");
            invalidRequest.setPassword("");

            mockMvc.perform(post("/api/v1/auth/login")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).loginWithEmailPassword(any(LoginRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when password is too short")
        @WithMockUser
        void login_ShortPassword_ReturnsBadRequest() throws Exception {
            LoginRequestDto invalidRequest = new LoginRequestDto();
            invalidRequest.setEmail("test@example.com");
            invalidRequest.setPassword("12345"); // Less than 6 characters

            mockMvc.perform(post("/api/v1/auth/login")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).loginWithEmailPassword(any(LoginRequestDto.class));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/login/google")
    class GoogleLoginTests {

        @Test
        @DisplayName("Should return auth response when Google login is successful")
        @WithMockUser
        void loginWithGoogle_Success() throws Exception {
            when(authService.loginWithGoogle(anyString())).thenReturn(mockAuthResponse);

            mockMvc.perform(post("/api/v1/auth/login/google")
                            .with(csrf())
                            .param("googleToken", "valid-google-token"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.accessToken").value("mock-access-token"))
                    .andExpect(jsonPath("$.message").value("Google login successful"));

            verify(authService, times(1)).loginWithGoogle("valid-google-token");
        }

        @Test
        @DisplayName("Should return 400 when googleToken parameter is missing")
        @WithMockUser
        void loginWithGoogle_MissingToken_ReturnsBadRequest() throws Exception {
            mockMvc.perform(post("/api/v1/auth/login/google")
                            .with(csrf()))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).loginWithGoogle(anyString());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/refresh")
    class RefreshTokenTests {

        @Test
        @DisplayName("Should return new auth response when refresh is successful")
        @WithMockUser
        void refresh_Success() throws Exception {
            when(authService.refreshAccessToken(anyString())).thenReturn(mockAuthResponse);

            mockMvc.perform(post("/api/v1/auth/refresh")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(validRefreshTokenRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.accessToken").value("mock-access-token"))
                    .andExpect(jsonPath("$.data.refreshToken").value("mock-refresh-token"))
                    .andExpect(jsonPath("$.message").value("Token refreshed successfully"));

            verify(authService, times(1)).refreshAccessToken("valid-refresh-token");
        }

        @Test
        @DisplayName("Should return 400 when refresh token is blank")
        @WithMockUser
        void refresh_BlankToken_ReturnsBadRequest() throws Exception {
            RefreshTokenRequest invalidRequest = new RefreshTokenRequest();
            invalidRequest.setRefreshToken("");

            mockMvc.perform(post("/api/v1/auth/refresh")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).refreshAccessToken(anyString());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/register")
    class RegisterTests {

        @Test
        @DisplayName("Should return success when registration is successful")
        @WithMockUser
        void register_Success() throws Exception {
            when(authService.registerUser(any(RegisterRequestDto.class))).thenReturn(true);

            mockMvc.perform(post("/api/v1/auth/register")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(validRegisterRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("Registration successful"));

            verify(authService, times(1)).registerUser(any(RegisterRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when username is blank")
        @WithMockUser
        void register_BlankUsername_ReturnsBadRequest() throws Exception {
            RegisterRequestDto invalidRequest = new RegisterRequestDto();
            invalidRequest.setUsername("");
            invalidRequest.setEmail("test@example.com");
            invalidRequest.setPassword("password123");
            invalidRequest.setConfirmPassword("password123");

            mockMvc.perform(post("/api/v1/auth/register")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).registerUser(any(RegisterRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when email is invalid")
        @WithMockUser
        void register_InvalidEmail_ReturnsBadRequest() throws Exception {
            RegisterRequestDto invalidRequest = new RegisterRequestDto();
            invalidRequest.setUsername("testuser");
            invalidRequest.setEmail("invalid-email");
            invalidRequest.setPassword("password123");
            invalidRequest.setConfirmPassword("password123");

            mockMvc.perform(post("/api/v1/auth/register")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).registerUser(any(RegisterRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when password is too short")
        @WithMockUser
        void register_ShortPassword_ReturnsBadRequest() throws Exception {
            RegisterRequestDto invalidRequest = new RegisterRequestDto();
            invalidRequest.setUsername("testuser");
            invalidRequest.setEmail("test@example.com");
            invalidRequest.setPassword("12345");
            invalidRequest.setConfirmPassword("12345");

            mockMvc.perform(post("/api/v1/auth/register")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).registerUser(any(RegisterRequestDto.class));
        }

        @Test
        @DisplayName("Should return 400 when date of birth is in the future")
        @WithMockUser
        void register_FutureDateOfBirth_ReturnsBadRequest() throws Exception {
            RegisterRequestDto invalidRequest = new RegisterRequestDto();
            invalidRequest.setUsername("testuser");
            invalidRequest.setEmail("test@example.com");
            invalidRequest.setPassword("password123");
            invalidRequest.setConfirmPassword("password123");

            mockMvc.perform(post("/api/v1/auth/register")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).registerUser(any(RegisterRequestDto.class));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/register/google")
    class GoogleRegisterTests {

        @Test
        @DisplayName("Should return success when Google registration is successful")
        @WithMockUser
        void registerWithGoogle_Success() throws Exception {
            when(authService.registerWithGoogle(anyString())).thenReturn(true);

            mockMvc.perform(post("/api/v1/auth/register/google")
                            .with(csrf())
                            .param("googleToken", "valid-google-token"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("Google registration successful"));

            verify(authService, times(1)).registerWithGoogle("valid-google-token");
        }

        @Test
        @DisplayName("Should return 400 when googleToken parameter is missing")
        @WithMockUser
        void registerWithGoogle_MissingToken_ReturnsBadRequest() throws Exception {
            mockMvc.perform(post("/api/v1/auth/register/google")
                            .with(csrf()))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).registerWithGoogle(anyString());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/logout")
    class LogoutTests {

        @Test
        @DisplayName("Should return success when logout is successful")
        @WithMockUser
        void logout_Success() throws Exception {
            when(authService.logout(anyString())).thenReturn(true);

            mockMvc.perform(post("/api/v1/auth/logout")
                            .with(csrf())
                            .param("email", "test@example.com"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("Logout successful"));

            verify(authService, times(1)).logout("test@example.com");
        }

        @Test
        @DisplayName("Should return 400 when email parameter is missing")
        @WithMockUser
        void logout_MissingEmail_ReturnsBadRequest() throws Exception {
            mockMvc.perform(post("/api/v1/auth/logout")
                            .with(csrf()))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).logout(anyString());
        }
    }
}
