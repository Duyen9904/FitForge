package com.dev.backend.controller;

import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.request.SelectMakeupOptionRequest;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.model.dto.response.MakeupWorkoutOptionResponse;
import com.dev.backend.model.dto.response.MakeupWorkoutResponse;
import com.dev.backend.model.dto.response.MissedWorkoutReportResponse;
import com.dev.backend.model.dto.response.MissedWorkoutResponse;
import com.dev.backend.service.MissedWorkoutService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/missed-workouts")
@Tag(name = "Missed Workout Management", description = "Missed workout tracking and makeup planning endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class MissedWorkoutController {

    private final MissedWorkoutService missedWorkoutService;

    public MissedWorkoutController(MissedWorkoutService missedWorkoutService) {
        this.missedWorkoutService = missedWorkoutService;
    }

    // ========== Get Missed Workouts ==========

    @Operation(summary = "Get missed workouts", description = "List all missed workouts")
    @GetMapping
    public ApiResponse<Page<MissedWorkoutResponse>> getMissedWorkouts(
            @AuthenticationPrincipal Jwt jwt,
            @PageableDefault(size = 20, sort = "scheduledDate", direction = Sort.Direction.DESC) Pageable pageable) {
        Long userId = Long.parseLong(jwt.getSubject());
        Page<MissedWorkoutResponse> response = missedWorkoutService.getMissedWorkouts(userId, pageable);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get unaddressed missed workouts", description = "Get missed workouts without makeup plan")
    @GetMapping("/unaddressed")
    public ApiResponse<List<MissedWorkoutResponse>> getUnaddressedMissedWorkouts(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<MissedWorkoutResponse> response = missedWorkoutService.getUnaddressedMissedWorkouts(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get missed workout by ID", description = "Get details of a specific missed workout")
    @GetMapping("/{missedWorkoutId}")
    public ApiResponse<MissedWorkoutResponse> getMissedWorkout(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long missedWorkoutId) {
        Long userId = Long.parseLong(jwt.getSubject());
        MissedWorkoutResponse response = missedWorkoutService.getMissedWorkout(userId, missedWorkoutId);
        return ApiResponse.success(response);
    }

    // ========== Makeup Options (UC-6.2) ==========

    @Operation(summary = "Get makeup options", description = "UC-6.2: Generate compensation strategies for missed workout")
    @GetMapping("/{missedWorkoutId}/makeup-options")
    public ApiResponse<List<MakeupWorkoutOptionResponse>> getMakeupOptions(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long missedWorkoutId) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<MakeupWorkoutOptionResponse> response = missedWorkoutService.generateMakeupOptions(userId, missedWorkoutId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Select makeup option", description = "UC-6.2: Choose and apply makeup strategy")
    @PostMapping("/{missedWorkoutId}/makeup")
    public ApiResponse<MissedWorkoutResponse> selectMakeupOption(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long missedWorkoutId,
            @Valid @RequestBody SelectMakeupOptionRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        MissedWorkoutResponse response = missedWorkoutService.selectMakeupOption(userId, missedWorkoutId, request);
        return ApiResponse.success(response, "Makeup option applied successfully");
    }

    // ========== Reschedule (UC-6.3) ==========

    @Operation(summary = "Reschedule missed workout", description = "UC-6.3: Manually reschedule to new date")
    @PutMapping("/{missedWorkoutId}/reschedule")
    public ApiResponse<MissedWorkoutResponse> rescheduleMissedWorkout(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long missedWorkoutId,
            @Valid @RequestBody RescheduleMissedWorkoutRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        MissedWorkoutResponse response = missedWorkoutService.rescheduleMissedWorkout(userId, missedWorkoutId, request);
        return ApiResponse.success(response, "Workout rescheduled successfully");
    }

    // ========== Active Makeup Workouts ==========

    @Operation(summary = "Get active makeup workouts", description = "List all scheduled (incomplete) makeup workouts for the user")
    @GetMapping("/makeup-workouts")
    public ApiResponse<List<MakeupWorkoutResponse>> getActiveMakeupWorkouts(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<MakeupWorkoutResponse> response = missedWorkoutService.getActiveMakeupWorkouts(userId);
        return ApiResponse.success(response);
    }

    // ========== Report (UC-6.4) ==========

    @Operation(summary = "Get missed workout report", description = "UC-6.4: View consistency metrics and patterns")
    @GetMapping("/report")
    public ApiResponse<MissedWorkoutReportResponse> getMissedWorkoutReport(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Start date (YYYY-MM-DD)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "End date (YYYY-MM-DD)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        MissedWorkoutReportResponse response = missedWorkoutService.getMissedWorkoutReport(userId, startDate, endDate);
        return ApiResponse.success(response);
    }
}
