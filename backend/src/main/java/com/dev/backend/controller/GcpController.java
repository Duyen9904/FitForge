package com.dev.backend.controller;

import com.dev.backend.model.dto.response.MediaUploadResponse;
import com.dev.backend.model.enums.MediaCategory;
import com.dev.backend.service.GcpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * REST controller for GCP Cloud Storage media operations.
 */
@RestController
@RequestMapping("/api/gcp")
@RequiredArgsConstructor
public class GcpController {

    private final GcpService gcpService;

    /**
     * Upload a file to GCS.
     *
     * @param file     multipart file
     * @param category media category (e.g. PROGRESS_PHOTO, MEAL_PROOF, WORKOUT_PROOF)
     * @param jwt      authenticated user's JWT
     * @return upload response with object path and signed URL
     */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<MediaUploadResponse> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam("category") MediaCategory category,
            @AuthenticationPrincipal Jwt jwt) {

        Long userId = Long.valueOf(jwt.getSubject());
        MediaUploadResponse response = gcpService.upload(file, category, userId);
        return ResponseEntity.ok(response);
    }

    /**
     * Get a fresh signed URL for an existing GCS object.
     *
     * @param objectPath the GCS object path
     * @return signed URL string
     */
    @GetMapping("/signed-url")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> getSignedUrl(@RequestParam("objectPath") String objectPath) {
        String signedUrl = gcpService.getSignedUrl(objectPath);
        return ResponseEntity.ok(signedUrl);
    }

    /**
     * Delete a media object from GCS.
     *
     * @param objectPath the GCS object path (URL-encoded)
     */
    @DeleteMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> delete(@RequestParam("objectPath") String objectPath) {
        gcpService.delete(objectPath);
        return ResponseEntity.noContent().build();
    }
}
