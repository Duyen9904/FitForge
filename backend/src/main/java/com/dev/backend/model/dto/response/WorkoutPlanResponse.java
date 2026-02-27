package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.DifficultyLevel;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutPlanResponse {

    private Long planId;
    private String planName;
    private String description;
    private GoalResponse goal;
    private MuscleGroupResponse muscleGroup;
    private Integer frequencyPerWeek;
    private Integer durationWeeks;
    private DifficultyLevel difficultyLevel;
    private LocalDate startDate;
    private List<LocalDate> scheduledWorkoutDates;

    // Recommendation metadata
    private String algorithmVersion;
    private String generatedFrom;
    private Integer version;
    private String recommendationReason;

    private Boolean aiGenerated;
    private Boolean allowWorkoutSwaps;
    private Boolean isActive;
    private Instant createdAt;
    private Instant updatedAt;
    private List<WorkoutSessionResponse> sessions;
}
