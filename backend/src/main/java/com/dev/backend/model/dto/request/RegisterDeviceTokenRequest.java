package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for registering/updating FCM device token (UC-15)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterDeviceTokenRequest {

    @NotBlank(message = "Device token is required")
    @Size(max = 500, message = "Device token must be at most 500 characters")
    private String deviceToken;

    @Size(max = 50, message = "Device type must be at most 50 characters")
    private String deviceType; // "ANDROID", "IOS", "WEB"
}
