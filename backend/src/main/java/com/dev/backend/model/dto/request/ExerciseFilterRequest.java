package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseFilterRequest {

    private List<Long> muscleGroupIds;
    private List<Long> equipmentIds;
    private DifficultyLevel difficultyLevel;
    private String exerciseType;
    private String searchQuery;
    private Boolean requiresSpotter;
    
    
    // UC-14.1: Additional filter options
    private Boolean recentlyUsed;

    // External API pass-through fields (for ExerciseDB v2 /api/v1/exercises)
    private String targetMuscles;   // comma-separated muscle names
    private String bodyParts;       // comma-separated body part names
    private String equipments;      // comma-separated equipment names
    private String keywords;        // comma-separated keywords
    private String after;           // cursor for forward pagination
    private String before;          // cursor for backward pagination
}
