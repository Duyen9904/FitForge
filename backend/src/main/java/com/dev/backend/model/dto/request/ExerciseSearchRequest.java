package com.dev.backend.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO encapsulating all query parameters for ExerciseDB v2 API
 * GET /api/v1/exercises endpoint.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseSearchRequest {

    /** Filter exercises by name (supports fuzzy matching) */
    private String name;

    /** Comma-separated keywords filter */
    private String keywords;

    /** Comma-separated primary target muscle names */
    private String targetMuscles;

    /** Comma-separated secondary muscle names */
    private String secondaryMuscles;

    /** Exercise type filter (e.g. "strength", "cardio") */
    private String exerciseType;

    /** Comma-separated body part names */
    private String bodyParts;

    /** Comma-separated equipment names */
    private String equipments;

    /** Maximum number of results (1–25, default 10) */
    private Integer limit;

    /** Exercise ID cursor for forward pagination */
    private String after;

    /** Exercise ID cursor for backward pagination */
    private String before;
}
