package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDto {

    // Short-lived token (5–15 minutes)
    private String accessToken;

    // Long-lived token (7–30 days)
    private String refreshToken;

    // Token type (always "Bearer")
    private String tokenType;

    // Access token expiration (epoch millis or seconds)
    private long expiresAt;

    // Minimal user info for frontend
    private AccountSummaryDto user;
}