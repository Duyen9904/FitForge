package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for progress photos (UC-8.4)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProgressPhotoResponse {

    private Long photoId;
    private LocalDate photoDate;
    private String photoUrl;
    private String category;
    private String notes;
}
