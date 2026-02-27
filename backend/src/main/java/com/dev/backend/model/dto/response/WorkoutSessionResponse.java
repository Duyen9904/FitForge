package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutSessionResponse {
    
    private Long sessionId;
    private String sessionName;
    private Integer dayNumber;
    private LocalDate scheduledDate;
    private String focusArea;
    private Integer estimatedDuration;
    private String warmUpNotes;
    private String coolDownNotes;
    private Boolean isRestDay;
    private Boolean isCompleted;
    private Long missedWorkoutId;
    private Boolean isMissed;
    private List<SessionExerciseResponse> exercises;
}
