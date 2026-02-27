package com.dev.backend.service.impl;

import com.dev.backend.model.dto.request.InBodyImportRequest;
import com.dev.backend.service.InBodyOcrService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

/**
 * Placeholder implementation of InBody OCR service.
 * 
 * TODO: Integrate with Google Cloud Vision API for production use.
 * This placeholder allows the application to compile and run while
 * the full OCR implementation is being developed.
 */
@Service
@Slf4j
public class InBodyOcrServiceImpl implements InBodyOcrService {

    @Override
    public InBodyImportRequest parseInBodyImage(MultipartFile image) {
        log.info("Parsing InBody image: {}", image.getOriginalFilename());
        
        // TODO: Implement Google Cloud Vision OCR integration
        // 1. Send image to Google Cloud Vision API
        // 2. Extract text from response
        // 3. Parse InBody-specific format to extract metrics
        // 4. Return populated InBodyImportRequest
        
        throw new UnsupportedOperationException(
            "InBody OCR parsing not yet implemented. " +
            "Please use the manual import endpoint: POST /api/v1/measurements/import/inbody/manual"
        );
    }
}
