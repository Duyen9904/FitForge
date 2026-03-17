package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutHistoryResponse {

    private Long progressId;
    private String planName;
    private String sessionName;
    private Instant workoutDate;
    private Integer durationMinutes;
    private Boolean completed;
    private Integer difficultyRating;
    private Integer caloriesBurned;
    private String moodRating;
    private Integer exercisesCompleted;
    private Integer exercisesSkipped;
    private Float totalVolumeKg;
    private String proofPhotoUrl;
}
