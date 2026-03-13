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
public class ExerciseLogResponse {

    private Long logId;
    private String exerciseId;
    private String exerciseName;
    private Integer setNumber;
    private Integer repetitionsCompleted;
    private Float weightUsedKg;
    private Integer restTimeSeconds;
    private Boolean completed;
    private Boolean skipped;
    private String skipReason;
    private String notes;
}
