package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GoalResponse {

    private Long goalId;
    private String goalName;
    private String description;
    private String recommendedRepRange;
    private String recommendedRestTime;
    private String recommendedFrequency;
    private Integer targetCalorieAdjustment;
}
