package com.dev.backend.model.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Generic wrapper for ExerciseDB v2 API list endpoints.
 * Used by: /api/v1/equipments, /api/v1/muscles, /api/v1/exercisetypes
 * Response format: { "success": true, "data": [{ "name": "...", "imageUrl": "..." }] }
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExerciseDBV2ListResponse {

    private boolean success;
    private List<Item> data;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Item {
        private String name;
        private String imageUrl;
    }
}
