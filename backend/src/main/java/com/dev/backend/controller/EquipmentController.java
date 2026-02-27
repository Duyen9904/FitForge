package com.dev.backend.controller;

import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.EquipmentResponse;
import com.dev.backend.model.dto.response.ExerciseSummaryResponse;
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
@RequestMapping("/api/v1/equipment")
@Tag(name = "Equipment", description = "Equipment management endpoints")
public class EquipmentController {

    private final ExerciseService exerciseService;

    public EquipmentController(ExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @Operation(summary = "Get all equipment", description = "List all available equipment")
    @GetMapping
    public ApiResponse<List<EquipmentResponse>> getAllEquipment() {
        List<EquipmentResponse> response = exerciseService.getAllEquipment();
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get equipment details", description = "View details of a specific equipment")
    @GetMapping("/{equipmentId}")
    public ApiResponse<EquipmentResponse> getEquipmentById(@PathVariable Long equipmentId) {
        EquipmentResponse response = exerciseService.getEquipmentById(equipmentId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get exercises for equipment", description = "List exercises using specific equipment")
    @GetMapping("/{equipmentId}/exercises")
    public ApiResponse<Page<ExerciseSummaryResponse>> getExercisesByEquipment(
            @PathVariable Long equipmentId,
            @PageableDefault(size = 20, sort = "exerciseName", direction = Sort.Direction.ASC) Pageable pageable) {
        Page<ExerciseSummaryResponse> response = exerciseService.getExercisesByEquipment(equipmentId, pageable);
        return ApiResponse.success(response);
    }
}
