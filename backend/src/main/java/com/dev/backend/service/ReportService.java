package com.dev.backend.service;

import com.dev.backend.model.dto.request.DataExportRequest;
import com.dev.backend.model.dto.response.NutritionReportResponse;
import com.dev.backend.model.dto.response.TransformationReportResponse;
import com.dev.backend.model.dto.response.WorkoutSummaryReportResponse;

import java.time.LocalDate;

public interface ReportService {

    /**
     * Generate workout summary report (UC-13.1)
     */
    WorkoutSummaryReportResponse generateWorkoutSummaryReport(Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * Generate nutrition report (UC-13.2)
     */
    NutritionReportResponse generateNutritionReport(Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * Generate body transformation report (UC-13.3)
     */
    TransformationReportResponse generateTransformationReport(Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * Export user data (UC-13.4)
     * Returns the exported data as byte array
     */
    byte[] exportData(Long userId, DataExportRequest request);
}
