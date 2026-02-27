package com.dev.backend.controller;

import com.dev.backend.model.dto.request.LoginRequestDto;
import com.dev.backend.model.dto.request.RefreshTokenRequest;
import com.dev.backend.model.dto.request.RegisterRequestDto;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.AuthResponseDto;
import com.dev.backend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Authentication endpoints")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Login with email and password")
    @PostMapping("/login")
    public ApiResponse<AuthResponseDto> login(@Valid @RequestBody LoginRequestDto loginRequestDto) {
        AuthResponseDto result = authService.loginWithEmailPassword(loginRequestDto);
        return ApiResponse.success(result, "Login successful");
    }

    @Operation(summary = "Login with Google")
    @PostMapping("/login/google")
    public ApiResponse<AuthResponseDto> loginWithGoogle(@RequestParam String googleToken) {
        AuthResponseDto result = authService.loginWithGoogle(googleToken);
        return ApiResponse.success(result, "Google login successful");
    }

    @Operation(summary = "Refresh access token")
    @PostMapping("/refresh")
    public ApiResponse<AuthResponseDto> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponseDto result = authService.refreshAccessToken(request.getRefreshToken());
        return ApiResponse.success(result, "Token refreshed successfully");
    }

    @Operation(summary = "Register new user")
    @PostMapping("/register")
    public ApiResponse<Void> register(@Valid @RequestBody RegisterRequestDto registerRequestDto) {
        authService.registerUser(registerRequestDto);
        return ApiResponse.success(null, "Registration successful");
    }

    @Operation(summary = "Register with Google")
    @PostMapping("/register/google")
    public ApiResponse<Void> registerWithGoogle(@RequestParam String googleToken) {
        authService.registerWithGoogle(googleToken);
        return ApiResponse.success(null, "Google registration successful");
    }

    @Operation(summary = "Logout")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/logout")
    public ApiResponse<Void> logout(@RequestParam String email) {
        authService.logout(email);
        return ApiResponse.success(null, "Logout successful");
    }
}

