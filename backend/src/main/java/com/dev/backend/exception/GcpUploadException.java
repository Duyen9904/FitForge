package com.dev.backend.exception;

/**
 * Custom exception for GCP media upload failures
 * (invalid file type, size exceeded, GCS errors).
 */
public class GcpUploadException extends RuntimeException {

    public GcpUploadException(String message) {
        super(message);
    }

    public GcpUploadException(String message, Throwable cause) {
        super(message, cause);
    }
}
