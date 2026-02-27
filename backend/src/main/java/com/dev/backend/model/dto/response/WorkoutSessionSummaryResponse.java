package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutSessionSummaryResponse {
    
    private Long sessionId;
    private String sessionName;
    private Integer dayNumber;
    private LocalDate scheduledDate;
    private String focusArea;
    private Integer estimatedDuration;
    private String warmUpNotes;
    private String coolDownNotes;
    private Boolean isRestDay;
    private Integer exerciseCount;
}
