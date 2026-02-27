package com.dev.backend.controller;

import com.dev.backend.model.dto.request.InBodyImportRequest;
import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.request.UploadProgressPhotoRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.service.MeasurementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/measurements")
@Tag(name = "Body Measurements", description = "Body measurement tracking and goal setting endpoints")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("isAuthenticated()")
public class MeasurementController {

    private final MeasurementService measurementService;

    public MeasurementController(MeasurementService measurementService) {
        this.measurementService = measurementService;
    }

    // ========== Measurements (UC-8.1, UC-8.2) ==========

    @Operation(summary = "Record body measurements", description = "UC-8.1: Log physical measurements")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MeasurementResponse> recordMeasurement(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody RecordMeasurementRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementResponse response = measurementService.recordMeasurement(userId, request);
        return ApiResponse.success(response, "Measurement recorded successfully");
    }

    @Operation(summary = "Get latest measurement", description = "Get the most recent measurement record")
    @GetMapping("/latest")
    public ApiResponse<MeasurementResponse> getLatestMeasurement(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementResponse response = measurementService.getLatestMeasurement(userId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Get measurement by ID", description = "Get a specific measurement record")
    @GetMapping("/{measurementId}")
    public ApiResponse<MeasurementResponse> getMeasurementById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long measurementId) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementResponse response = measurementService.getMeasurementById(userId, measurementId);
        return ApiResponse.success(response);
    }

    @Operation(summary = "View measurement history", description = "UC-8.2: Review measurement trends")
    @GetMapping
    public ApiResponse<MeasurementHistoryResponse> getMeasurementHistory(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Start date (YYYY-MM-DD)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "End date (YYYY-MM-DD)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementHistoryResponse response = measurementService.getMeasurementHistory(userId, startDate, endDate);
        return ApiResponse.success(response);
    }

    // ========== InBody Import (UC-8.5) ==========

    @Operation(summary = "Import InBody report via OCR", 
               description = "UC-8.5: Upload InBody report image for automatic data extraction via OCR")
    @PostMapping(value = "/import/inbody", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MeasurementResponse> importInBodyReport(
            @AuthenticationPrincipal Jwt jwt,
            @RequestPart("file") MultipartFile file) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementResponse response = measurementService.importInBodyReport(userId, file);
        return ApiResponse.success(response, "InBody data imported successfully");
    }

    @Operation(summary = "Manually import InBody data", 
               description = "UC-8.5: Manually enter InBody data (fallback when OCR fails)")
    @PostMapping("/import/inbody/manual")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MeasurementResponse> importInBodyManual(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody InBodyImportRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementResponse response = measurementService.importInBodyManual(userId, request);
        return ApiResponse.success(response, "InBody data imported successfully");
    }

    // ========== Goals (UC-8.3) ==========

    @Operation(summary = "Set measurement goals", description = "UC-8.3: Define target measurements")
    @PostMapping("/goals")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MeasurementGoalResponse> setMeasurementGoal(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody SetMeasurementGoalRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementGoalResponse response = measurementService.setMeasurementGoal(userId, request);
        return ApiResponse.success(response, "Measurement goal set successfully");
    }

    @Operation(summary = "Get current measurement goal", description = "Get active measurement goal")
    @GetMapping("/goals")
    public ApiResponse<MeasurementGoalResponse> getMeasurementGoal(@AuthenticationPrincipal Jwt jwt) {
        Long userId = Long.parseLong(jwt.getSubject());
        MeasurementGoalResponse response = measurementService.getMeasurementGoal(userId);
        return ApiResponse.success(response);
    }

    // ========== Progress Photos (UC-8.4) ==========

    @Operation(summary = "Upload progress photo", description = "UC-8.4: Upload transformation photo")
    @PostMapping(value = "/photos", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ProgressPhotoResponse> uploadProgressPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @RequestPart("file") MultipartFile file,
            @RequestPart("data") @Valid UploadProgressPhotoRequest request) {
        Long userId = Long.parseLong(jwt.getSubject());
        ProgressPhotoResponse response = measurementService.uploadProgressPhoto(userId, file, request);
        return ApiResponse.success(response, "Photo uploaded successfully");
    }

    @Operation(summary = "Get progress photos", description = "UC-8.4: View all progress photos")
    @GetMapping("/photos")
    public ApiResponse<List<ProgressPhotoResponse>> getProgressPhotos(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Filter by category (front, side, back)")
            @RequestParam(required = false) String category) {
        Long userId = Long.parseLong(jwt.getSubject());
        List<ProgressPhotoResponse> response;
        if (category != null && !category.isBlank()) {
            response = measurementService.getProgressPhotosByCategory(userId, category);
        } else {
            response = measurementService.getProgressPhotos(userId);
        }
        return ApiResponse.success(response);
    }

    @Operation(summary = "Delete progress photo", description = "Remove a progress photo")
    @DeleteMapping("/photos/{photoId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteProgressPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long photoId) {
        Long userId = Long.parseLong(jwt.getSubject());
        measurementService.deleteProgressPhoto(userId, photoId);
        return ApiResponse.success(null, "Photo deleted successfully");
    }
}
