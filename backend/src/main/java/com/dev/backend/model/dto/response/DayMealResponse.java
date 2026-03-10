package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MealType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Response DTO for a meal slot within a nutrition day.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DayMealResponse {

    private Long dayMealId;
    private MealType mealType;
    private Integer orderIndex;

    // Effective values: custom overrides if set, else from template
    private Integer calories;
    private Float proteinG;
    private Float carbsG;
    private Float fatsG;

    private String notes;

    private Instant completedAt;

    /** GCS object path for proof photo (if uploaded) */
    private String proofPhotoUrl;

    /** Resolved signed URL for the proof photo (if available) */
    private String proofPhotoSignedUrl;

    // Full template details
    private MealTemplateResponse mealTemplate;
}
