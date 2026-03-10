package com.dev.backend.service.impl;

import com.dev.backend.exception.GcpUploadException;
import com.dev.backend.model.dto.response.MediaUploadResponse;
import com.dev.backend.model.enums.MediaCategory;
import com.dev.backend.service.GcpService;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URL;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * GCP Cloud Storage implementation for media upload, signed-URL generation, and deletion.
 */
@Service
public class GcpServiceImpl implements GcpService {

    private static final Logger logger = LoggerFactory.getLogger(GcpServiceImpl.class);

    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp"
    );
    private static final Set<String> ALLOWED_VIDEO_TYPES = Set.of(
            "video/mp4", "video/quicktime"
    );

    private final Storage storage;

    @Value("${gcs.bucket-name:fitforge-media}")
    private String bucketName;

    @Value("${gcs.signed-url.duration-minutes:60}")
    private int signedUrlDurationMinutes;

    @Value("${gcs.max-image-size-mb:10}")
    private int maxImageSizeMb;

    @Value("${gcs.max-video-size-mb:100}")
    private int maxVideoSizeMb;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    public GcpServiceImpl(Storage storage) {
        this.storage = storage;
    }

    @Override
    public MediaUploadResponse upload(MultipartFile file, MediaCategory category, Long userId) {
        if (!gcsEnabled || storage == null) {
            throw new GcpUploadException("GCS is not enabled or not configured");
        }

        if (file.isEmpty()) {
            throw new GcpUploadException("File is empty");
        }

        String contentType = file.getContentType();
        long fileSize = file.getSize();

        // Validate content type and size
        validateFile(contentType, fileSize, category);

        // Generate unique object path: {category}/{userId}/{UUID}.{extension}
        String extension = getExtension(file.getOriginalFilename());
        String objectPath = String.format("%s/%d/%s.%s",
                category.name().toLowerCase(),
                userId,
                UUID.randomUUID(),
                extension
        );

        try {
            BlobId blobId = BlobId.of(bucketName, objectPath);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                    .setContentType(contentType)
                    .build();

            storage.create(blobInfo, file.getBytes());
            logger.info("Uploaded file to GCS: {} ({} bytes)", objectPath, fileSize);

            String signedUrl = generateSignedUrl(objectPath);

            return MediaUploadResponse.builder()
                    .objectPath(objectPath)
                    .signedUrl(signedUrl)
                    .contentType(contentType)
                    .fileSizeBytes(fileSize)
                    .build();

        } catch (IOException e) {
            throw new GcpUploadException("Failed to upload file to GCS", e);
        }
    }

    @Override
    public String getSignedUrl(String objectPath) {
        if (!gcsEnabled || storage == null) {
            throw new GcpUploadException("GCS is not enabled or not configured");
        }

        return generateSignedUrl(objectPath);
    }

    @Override
    public void delete(String objectPath) {
        if (!gcsEnabled || storage == null) {
            throw new GcpUploadException("GCS is not enabled or not configured");
        }

        BlobId blobId = BlobId.of(bucketName, objectPath);
        boolean deleted = storage.delete(blobId);

        if (deleted) {
            logger.info("Deleted file from GCS: {}", objectPath);
        } else {
            logger.warn("File not found in GCS for deletion: {}", objectPath);
        }
    }

    // ==================== Private Helpers ====================

    private void validateFile(String contentType, long fileSize, MediaCategory category) {
        if (contentType == null) {
            throw new GcpUploadException("File content type is missing");
        }

        boolean isImage = ALLOWED_IMAGE_TYPES.contains(contentType);
        boolean isVideo = ALLOWED_VIDEO_TYPES.contains(contentType);

        if (!isImage && !isVideo) {
            throw new GcpUploadException(
                    "Unsupported file type: " + contentType +
                    ". Allowed images: " + ALLOWED_IMAGE_TYPES +
                    ", Allowed videos: " + ALLOWED_VIDEO_TYPES
            );
        }

        long maxSizeBytes;
        if (isImage) {
            maxSizeBytes = (long) maxImageSizeMb * 1024 * 1024;
            if (fileSize > maxSizeBytes) {
                throw new GcpUploadException(
                        String.format("Image size %d bytes exceeds max %d MB", fileSize, maxImageSizeMb)
                );
            }
        } else {
            maxSizeBytes = (long) maxVideoSizeMb * 1024 * 1024;
            if (fileSize > maxSizeBytes) {
                throw new GcpUploadException(
                        String.format("Video size %d bytes exceeds max %d MB", fileSize, maxVideoSizeMb)
                );
            }
        }

        // Validate category-file type match
        if (isVideo && !isVideoCategory(category)) {
            throw new GcpUploadException("Video files are only allowed for video categories (EXERCISE_VIDEO)");
        }
    }

    private boolean isVideoCategory(MediaCategory category) {
        return category == MediaCategory.EXERCISE_VIDEO;
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "bin";
        }
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    }

    private String generateSignedUrl(String objectPath) {
        BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(bucketName, objectPath)).build();
        URL url = storage.signUrl(blobInfo, signedUrlDurationMinutes, TimeUnit.MINUTES);
        return url.toString();
    }
}
