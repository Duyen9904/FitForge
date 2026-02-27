package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutTemplateSummaryResponse {

    private Long id;
    private String name;
    private String goalType;
    private String experienceLevel;
    private Integer daysPerWeek;
    private String equipmentTags;
    private String recommendationReason;
}

