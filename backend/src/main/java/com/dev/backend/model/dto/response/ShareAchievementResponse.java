package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO after sharing an achievement (UC-10.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShareAchievementResponse {
    
    private Boolean success;
    private String shareableLink;
    private String shareableImageUrl;
    private String platform;
    private String message;
}
