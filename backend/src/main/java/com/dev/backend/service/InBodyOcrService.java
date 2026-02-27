package com.dev.backend.service;

import com.dev.backend.model.dto.request.InBodyImportRequest;
import org.springframework.web.multipart.MultipartFile;

/**
 * Service interface for InBody report OCR processing.
 * Uses Google Cloud Vision API to extract body composition data from InBody reports.
 */
public interface InBodyOcrService {

    /**
     * Parse InBody report image using OCR and extract body composition data.
     * 
     * @param image The InBody report image file
     * @return Parsed InBody data as import request DTO
     * @throws RuntimeException if OCR processing fails
     */
    InBodyImportRequest parseInBodyImage(MultipartFile image);
}
