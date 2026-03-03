package com.dev.backend.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserPreferenceRequest {

    private Integer preferredWorkoutDuration;
    private String preferredWorkoutTime;
    private Boolean allowAiSuggestions;
    private Boolean notificationEnabled;
    private String measurementUnit;
    private String workoutReminderDays;
    private Integer dailyCalorieTarget;
    private Float dailyProteinTargetG;
    private Float dailyCarbsTargetG;
    private Float dailyFatsTargetG;
}
