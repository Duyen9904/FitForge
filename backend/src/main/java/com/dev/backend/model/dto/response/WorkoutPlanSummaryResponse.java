package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.DifficultyLevel;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutPlanSummaryResponse {

    private Long planId;
    private String planName;
    private String description;
    private String goalName;
    private MuscleGroupResponse muscleGroup;
    private Integer frequencyPerWeek;
    private Integer durationWeeks;
    private DifficultyLevel difficultyLevel;
    private LocalDate startDate;
    private Boolean aiGenerated;
    private Boolean isActive;
    private Integer sessionCount;
    private Instant createdAt;
}
