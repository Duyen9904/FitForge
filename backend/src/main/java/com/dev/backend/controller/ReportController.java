package com.dev.backend.controller;

import com.dev.backend.model.dto.request.DataExportRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "Reports", description = "Reporting and analytics endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @Operation(summary = "Generate workout summary report", description = "UC-13.1: Generate comprehensive workout performance report with total workouts, duration, calories, adherence, and recommendations")
    @GetMapping("/workout-summary")
    public ApiResponse<WorkoutSummaryReportResponse> getWorkoutSummaryReport(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        WorkoutSummaryReportResponse response = reportService.generateWorkoutSummaryReport(userId, startDate, endDate);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Generate nutrition report", description = "UC-13.2: Generate dietary analysis report with average calories, macros, adherence, and cheat meal trends")
    @GetMapping("/nutrition")
    public ApiResponse<NutritionReportResponse> getNutritionReport(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        NutritionReportResponse response = reportService.generateNutritionReport(userId, startDate, endDate);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Generate transformation report", description = "UC-13.3: Generate body transformation report with weight changes, measurements, and achievement timeline")
    @GetMapping("/transformation")
    public ApiResponse<TransformationReportResponse> getTransformationReport(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        TransformationReportResponse response = reportService.generateTransformationReport(userId, startDate, endDate);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Export user data", description = "UC-13.4: Export personal fitness data in specified format (CSV, JSON, PDF)")
    @PostMapping("/export")
    public ResponseEntity<byte[]> exportData(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody DataExportRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        byte[] data = reportService.exportData(userId, request);

        String contentType;
        String filename;
        switch (request.getFormat()) {
            case CSV:
                contentType = "text/csv";
                filename = "fitness_export.csv";
                break;
            case PDF:
                contentType = "application/pdf";
                filename = "fitness_export.pdf";
                break;
            default:
                contentType = "application/json";
                filename = "fitness_export.json";
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.parseMediaType(contentType))
                .body(data);
    }
}
