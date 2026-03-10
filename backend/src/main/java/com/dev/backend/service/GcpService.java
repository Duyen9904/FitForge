package com.dev.backend.service;

import com.dev.backend.model.dto.response.MediaUploadResponse;
import com.dev.backend.model.enums.MediaCategory;
import org.springframework.web.multipart.MultipartFile;

/**
 * Service interface for GCP Cloud Storage media operations.
 */
public interface GcpService {

    /**
     * Upload a file to GCS and return upload metadata.
     *
     * @param file     the multipart file to upload
     * @param category the media category (determines GCS path prefix)
     * @param userId   the ID of the uploading user
     * @return upload response with object path and signed URL
     */
    MediaUploadResponse upload(MultipartFile file, MediaCategory category, Long userId);

    /**
     * Generate a time-limited signed URL for reading an existing object.
     *
     * @param objectPath the GCS object path
     * @return a signed URL string
     */
    String getSignedUrl(String objectPath);

    /**
     * Delete an object from the GCS bucket.
     *
     * @param objectPath the GCS object path to delete
     */
    void delete(String objectPath);
}
