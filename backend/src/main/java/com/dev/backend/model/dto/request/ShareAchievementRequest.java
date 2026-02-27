package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for sharing an achievement (UC-10.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShareAchievementRequest {
    
    @NotBlank(message = "Platform is required")
    private String platform; // "facebook", "twitter", "instagram", "link"
    
    private String customMessage; // Optional custom message to include
}
