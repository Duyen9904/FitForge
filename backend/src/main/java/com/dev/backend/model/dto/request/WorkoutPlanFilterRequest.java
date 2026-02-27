package com.dev.backend.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutPlanFilterRequest {

    private Boolean isActive;
    private Long goalId;
    private Long muscleGroupId;
    private Boolean aiGenerated;
    private LocalDate createdAfter;
    private LocalDate createdBefore;
    private String searchQuery;
}
