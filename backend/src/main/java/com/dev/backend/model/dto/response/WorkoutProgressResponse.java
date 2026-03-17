package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkoutProgressResponse {

    private Long progressId;
    private Long planId;
    private String planName;
    private Long sessionId;
    private String sessionName;
    private Instant workoutDate;
    private Instant startTime;
    private Instant endTime;
    private Integer durationMinutes;
    private Boolean completed;
    private String performanceNotes;
    private Integer difficultyRating;
    private Integer caloriesBurned;
    private Float averageHeartRate;
    private String moodRating;
    private String proofPhotoUrl;
    private List<ExerciseLogResponse> exerciseLogs;
}
