package com.dev.backend.controller;

import com.dev.backend.model.dto.response.AdminAnalyticsResponse;
import com.dev.backend.model.dto.response.ApiResponse;
import com.dev.backend.service.AdminAnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Admin-only controller for system administration (UC-16.3)
 */
@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin", description = "System administration endpoints (Admin only)")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminAnalyticsService adminAnalyticsService;

    public AdminController(AdminAnalyticsService adminAnalyticsService) {
        this.adminAnalyticsService = adminAnalyticsService;
    }

    @Operation(summary = "Get system analytics", description = "UC-16.3: View system-wide usage statistics including active users, workout stats, popular exercises, adherence rates, and feature usage")
    @GetMapping("/analytics")
    public ApiResponse<AdminAnalyticsResponse> getSystemAnalytics() {
        AdminAnalyticsResponse analytics = adminAnalyticsService.getSystemAnalytics();
        return ApiResponse.success(analytics);
    }

    @Operation(summary = "Export analytics report", description = "UC-16.3: Export analytics data as CSV file")
    @GetMapping("/analytics/export")
    public ResponseEntity<byte[]> exportAnalyticsReport() {
        byte[] csvData = adminAnalyticsService.exportAnalyticsReport();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.setContentDispositionFormData("attachment", "analytics_report.csv");
        headers.setCacheControl("must-revalidate, post-check=0, pre-check=0");

        return ResponseEntity.ok()
                .headers(headers)
                .body(csvData);
    }
}
