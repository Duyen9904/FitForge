package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Wrapper for ExerciseDB v2 API paginated response envelope.
 * The API returns: { "success": true, "meta": {...}, "data": [...] }
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExerciseDBV2PageResponse {

    private boolean success;
    private Meta meta;
    private List<ExerciseDBResponse> data;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Meta {
        private String nextCursor;
        private String previousCursor;
        private Integer totalCount;
    }
}
