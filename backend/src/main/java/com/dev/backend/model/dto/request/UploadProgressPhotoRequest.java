package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for uploading progress photos (UC-8.4)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadProgressPhotoRequest {

    @NotNull(message = "Photo date is required")
    @PastOrPresent(message = "Photo date cannot be in the future")
    private LocalDate photoDate;

    @NotBlank(message = "Category is required")
    @Pattern(regexp = "^(front|side|back)$", message = "Category must be 'front', 'side', or 'back'")
    private String category;

    private String notes;
}
