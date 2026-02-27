package com.dev.backend.controller;

import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.ExerciseSummaryResponse;
import com.dev.backend.model.dto.response.MuscleGroupResponse;
import com.dev.backend.service.ExerciseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/muscle-groups")
@Tag(name = "Muscle Groups", description = "Muscle group management endpoints")
public class MuscleGroupController {

    private final ExerciseService exerciseService;

    public MuscleGroupController(ExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @Operation(summary = "Get all muscle groups", description = "List all available muscle groups")
    @GetMapping
    public ApiResponse<List<MuscleGroupResponse>> getAllMuscleGroups() {
        List<MuscleGroupResponse> response = exerciseService.getAllMuscleGroups();
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get exercises for muscle group", description = "List exercises targeting a specific muscle group")
    @GetMapping("/{muscleGroupId}/exercises")
    public ApiResponse<Page<ExerciseSummaryResponse>> getExercisesByMuscleGroup(
            @PathVariable Long muscleGroupId,
            @PageableDefault(size = 20, sort = "exerciseName", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ExerciseSummaryResponse> response = exerciseService.getExercisesByMuscleGroup(muscleGroupId, pageable);
        return ApiResponse.success(response);
    }
}
