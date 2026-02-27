package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for makeup workout (UC-11.4)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MakeupWorkoutResponse {
    
    private Long makeupId;
    private Long originalSessionId;
    private String originalSessionName;
    private Long replacementSessionId;
    private LocalDate scheduledMakeupDate;
    private String adjustmentType;
    private String adjustmentNotes;
    private Boolean isCompleted;
}
