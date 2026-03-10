package com.dev.backend.service.impl;

import com.dev.backend.exception.GcpUploadException;
import com.dev.backend.model.dto.response.MediaUploadResponse;
import com.dev.backend.model.enums.MediaCategory;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

import java.net.URL;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GcpServiceImplTest {

    @Mock
    private Storage storage;

    private GcpServiceImpl gcpService;

    @BeforeEach
    void setUp() {
        gcpService = new GcpServiceImpl(storage);
        ReflectionTestUtils.setField(gcpService, "bucketName", "test-bucket");
        ReflectionTestUtils.setField(gcpService, "signedUrlDurationMinutes", 60);
        ReflectionTestUtils.setField(gcpService, "maxImageSizeMb", 10);
        ReflectionTestUtils.setField(gcpService, "maxVideoSizeMb", 100);
        ReflectionTestUtils.setField(gcpService, "gcsEnabled", true);
    }

    @Nested
    @DisplayName("upload()")
    class UploadTests {

        @Test
        @DisplayName("Should upload JPEG image successfully")
        void shouldUploadJpegImageSuccessfully() throws Exception {
            MockMultipartFile file = new MockMultipartFile(
                    "file", "photo.jpg", "image/jpeg", new byte[1024]
            );

            when(storage.create(any(BlobInfo.class), any(byte[].class)))
                    .thenReturn(null);
            when(storage.signUrl(any(BlobInfo.class), eq(60L), eq(TimeUnit.MINUTES)))
                    .thenReturn(new URL("https://storage.googleapis.com/signed-url"));

            MediaUploadResponse response = gcpService.upload(file, MediaCategory.PROGRESS_PHOTO, 1L);

            assertNotNull(response);
            assertTrue(response.getObjectPath().startsWith("progress_photo/1/"));
            assertTrue(response.getObjectPath().endsWith(".jpg"));
            assertEquals("image/jpeg", response.getContentType());
            assertEquals(1024, response.getFileSizeBytes());
            assertEquals("https://storage.googleapis.com/signed-url", response.getSignedUrl());

            verify(storage).create(any(BlobInfo.class), any(byte[].class));
        }

        @Test
        @DisplayName("Should upload PNG meal proof photo successfully")
        void shouldUploadMealProofSuccessfully() throws Exception {
            MockMultipartFile file = new MockMultipartFile(
                    "file", "meal.png", "image/png", new byte[2048]
            );

            when(storage.create(any(BlobInfo.class), any(byte[].class)))
                    .thenReturn(null);
            when(storage.signUrl(any(BlobInfo.class), eq(60L), eq(TimeUnit.MINUTES)))
                    .thenReturn(new URL("https://storage.googleapis.com/signed-url"));

            MediaUploadResponse response = gcpService.upload(file, MediaCategory.MEAL_PROOF, 5L);

            assertNotNull(response);
            assertTrue(response.getObjectPath().startsWith("meal_proof/5/"));
            assertTrue(response.getObjectPath().endsWith(".png"));
        }

        @Test
        @DisplayName("Should reject unsupported file type")
        void shouldRejectUnsupportedFileType() {
            MockMultipartFile file = new MockMultipartFile(
                    "file", "doc.pdf", "application/pdf", new byte[1024]
            );

            GcpUploadException ex = assertThrows(GcpUploadException.class, () ->
                    gcpService.upload(file, MediaCategory.PROGRESS_PHOTO, 1L)
            );

            assertTrue(ex.getMessage().contains("Unsupported file type"));
            verify(storage, never()).create(any(BlobInfo.class), any(byte[].class));
        }

        @Test
        @DisplayName("Should reject image exceeding size limit")
        void shouldRejectOversizedImage() {
            // 11 MB > 10 MB limit
            byte[] largeFile = new byte[11 * 1024 * 1024];
            MockMultipartFile file = new MockMultipartFile(
                    "file", "big.jpg", "image/jpeg", largeFile
            );

            GcpUploadException ex = assertThrows(GcpUploadException.class, () ->
                    gcpService.upload(file, MediaCategory.PROGRESS_PHOTO, 1L)
            );

            assertTrue(ex.getMessage().contains("exceeds max"));
        }

        @Test
        @DisplayName("Should reject empty file")
        void shouldRejectEmptyFile() {
            MockMultipartFile file = new MockMultipartFile(
                    "file", "empty.jpg", "image/jpeg", new byte[0]
            );

            GcpUploadException ex = assertThrows(GcpUploadException.class, () ->
                    gcpService.upload(file, MediaCategory.PROGRESS_PHOTO, 1L)
            );

            assertTrue(ex.getMessage().contains("empty"));
        }

        @Test
        @DisplayName("Should reject video for non-video category")
        void shouldRejectVideoForPhotoCategory() {
            MockMultipartFile file = new MockMultipartFile(
                    "file", "video.mp4", "video/mp4", new byte[1024]
            );

            GcpUploadException ex = assertThrows(GcpUploadException.class, () ->
                    gcpService.upload(file, MediaCategory.MEAL_PROOF, 1L)
            );

            assertTrue(ex.getMessage().contains("Video files are only allowed"));
        }

        @Test
        @DisplayName("Should throw when GCS is disabled")
        void shouldThrowWhenGcsDisabled() {
            ReflectionTestUtils.setField(gcpService, "gcsEnabled", false);

            MockMultipartFile file = new MockMultipartFile(
                    "file", "photo.jpg", "image/jpeg", new byte[1024]
            );

            GcpUploadException ex = assertThrows(GcpUploadException.class, () ->
                    gcpService.upload(file, MediaCategory.PROGRESS_PHOTO, 1L)
            );

            assertTrue(ex.getMessage().contains("not enabled"));
        }
    }

    @Nested
    @DisplayName("delete()")
    class DeleteTests {

        @Test
        @DisplayName("Should delete object with correct BlobId")
        void shouldDeleteWithCorrectBlobId() {
            String objectPath = "progress_photo/1/abc-123.jpg";
            when(storage.delete(any(BlobId.class))).thenReturn(true);

            gcpService.delete(objectPath);

            ArgumentCaptor<BlobId> captor = ArgumentCaptor.forClass(BlobId.class);
            verify(storage).delete(captor.capture());

            BlobId captured = captor.getValue();
            assertEquals("test-bucket", captured.getBucket());
            assertEquals(objectPath, captured.getName());
        }
    }

    @Nested
    @DisplayName("getSignedUrl()")
    class SignedUrlTests {

        @Test
        @DisplayName("Should generate signed URL for object path")
        void shouldGenerateSignedUrl() throws Exception {
            String objectPath = "meal_proof/5/xyz.png";
            when(storage.signUrl(any(BlobInfo.class), eq(60L), eq(TimeUnit.MINUTES)))
                    .thenReturn(new URL("https://storage.googleapis.com/signed"));

            String url = gcpService.getSignedUrl(objectPath);

            assertEquals("https://storage.googleapis.com/signed", url);
            verify(storage).signUrl(any(BlobInfo.class), eq(60L), eq(TimeUnit.MINUTES));
        }
    }
}
