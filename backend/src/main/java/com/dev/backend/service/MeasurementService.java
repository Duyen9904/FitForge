package com.dev.backend.service;

import com.dev.backend.model.dto.request.InBodyImportRequest;
import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.request.UploadProgressPhotoRequest;
import com.dev.backend.model.dto.response.MeasurementGoalResponse;
import com.dev.backend.model.dto.response.MeasurementHistoryResponse;
import com.dev.backend.model.dto.response.MeasurementResponse;
import com.dev.backend.model.dto.response.ProgressPhotoResponse;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;

/**
 * Service interface for body measurement tracking (UC-8)
 */
public interface MeasurementService {

    /**
     * Record body measurements (UC-8.1)
     */
    MeasurementResponse recordMeasurement(Long userId, RecordMeasurementRequest request);

    /**
     * Get the latest measurement for a user
     */
    MeasurementResponse getLatestMeasurement(Long userId);

    /**
     * Get measurement by ID
     */
    MeasurementResponse getMeasurementById(Long userId, Long measurementId);

    /**
     * View measurement history with trends (UC-8.2)
     */
    MeasurementHistoryResponse getMeasurementHistory(Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * Set measurement goals (UC-8.3)
     */
    MeasurementGoalResponse setMeasurementGoal(Long userId, SetMeasurementGoalRequest request);

    /**
     * Get current measurement goal
     */
    MeasurementGoalResponse getMeasurementGoal(Long userId);

    /**
     * Upload progress photo (UC-8.4)
     */
    ProgressPhotoResponse uploadProgressPhoto(Long userId, MultipartFile file, UploadProgressPhotoRequest request);

    /**
     * Get all progress photos
     */
    List<ProgressPhotoResponse> getProgressPhotos(Long userId);

    /**
     * Get progress photos by category
     */
    List<ProgressPhotoResponse> getProgressPhotosByCategory(Long userId, String category);

    /**
     * Delete a progress photo
     */
    void deleteProgressPhoto(Long userId, Long photoId);

    /**
     * Import InBody report via OCR (UC-8.5)
     * @param userId The user ID
     * @param file The InBody report image file
     * @return The created measurement from OCR data
     */
    MeasurementResponse importInBodyReport(Long userId, MultipartFile file);

    /**
     * Manually import InBody data (fallback when OCR fails)
     * @param userId The user ID
     * @param request The manually entered InBody data
     * @return The created measurement
     */
    MeasurementResponse importInBodyManual(Long userId, InBodyImportRequest request);
}
