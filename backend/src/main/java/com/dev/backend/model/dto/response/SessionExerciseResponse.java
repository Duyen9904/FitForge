package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionExerciseResponse {
    
    private Long sessionExerciseId;
    private ExerciseSummaryResponse exercise;
    private Integer sets;
    private Integer repetitions;
    private Float weightKg;
    private Integer restTimeSeconds;
    private Integer orderIndex;
    private String notes;
    private Boolean isSuperset;
    private List<EquipmentResponse> equipmentUsed;
}
