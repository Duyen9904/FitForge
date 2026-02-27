package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.DifficultyLevel;
import com.dev.backend.model.enums.ExerciseType;
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
    private ExerciseType exerciseType;
    private String searchQuery;
    private Boolean requiresSpotter;
    
    // UC-14.1: Additional filter options
    private Boolean favoritesOnly;
    private Boolean recentlyUsed;
}
