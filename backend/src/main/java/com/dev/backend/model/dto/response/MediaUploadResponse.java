package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for a successful media upload to GCS.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MediaUploadResponse {

    /** GCS object path (key), stored in database entities */
    private String objectPath;

    /** Time-limited signed URL for the client to read the file */
    private String signedUrl;

    /** MIME content type of the uploaded file */
    private String contentType;

    /** Size of the uploaded file in bytes */
    private long fileSizeBytes;
}
