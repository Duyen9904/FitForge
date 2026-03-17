package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Unified response for the profile screen.
 * Combines check-in photo gallery and activity heatmap in a single API call.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProfileSummaryResponse {

    /** GitHub-style activity heatmap data */
    private ActivityHeatmapResponse activityHeatmap;

    /** Instagram-style check-in photo gallery */
    private List<CheckInPhotoResponse> checkInPhotos;

    /** Total completed workouts (all time) */
    private int totalWorkoutsCompleted;
}
