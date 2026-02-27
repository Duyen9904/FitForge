package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MissedWorkoutReason;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for missed workout (UC-6.1)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MissedWorkoutResponse {

    private Long missedWorkoutId;
    private Long sessionId;
    private String sessionName;
    private String planName;
    private LocalDate scheduledDate;
    private LocalDate missedDate;
    private MissedWorkoutReason reason;
    private String customReasonText;
    private Boolean isReplanned;
    private String replanStrategy;
    private List<CompensationActionResponse> compensationActions;
}
