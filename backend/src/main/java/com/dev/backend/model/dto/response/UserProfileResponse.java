package com.dev.backend.model.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserProfileResponse {

    private Long userId;
    private String username;
    private String email;
    private LocalDate dateOfBirth;
    private String gender;
    private Float heightCm;
    private Float currentWeightKg;
    private Float targetWeightKg;
    private String fitnessLevel;
    private Boolean onboardingCompleted;
    private GoalResponse primaryGoal;
    private UserPreferenceResponse userPreference;
}
