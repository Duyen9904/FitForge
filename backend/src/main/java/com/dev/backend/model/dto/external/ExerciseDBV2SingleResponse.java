package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Wrapper for ExerciseDB v2 API single-exercise response.
 * The get-by-ID endpoint returns: { "success": true, "data": { ... } }
 * where "data" is a single object (NOT an array like the list endpoint).
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExerciseDBV2SingleResponse {

    private boolean success;
    private ExerciseDBResponse data;
}
