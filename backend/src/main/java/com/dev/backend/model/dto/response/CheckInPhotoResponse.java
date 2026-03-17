package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Lightweight DTO for the check-in photo gallery (Instagram-style grid).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CheckInPhotoResponse {

    private Long progressId;
    private String sessionName;
    private String planName;
    private Instant workoutDate;
    private Integer durationMinutes;
    private String proofPhotoUrl;
}
