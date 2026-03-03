package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.UserPreferenceResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserPreference;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    private final GoalMapper goalMapper;

    public UserMapper(GoalMapper goalMapper) {
        this.goalMapper = goalMapper;
    }

    public UserProfileResponse toUserProfileResponse(User user) {
        if (user == null) {
            return null;
        }
        return UserProfileResponse.builder()
                .userId(user.getUserId())
                .username(user.getUsername())
                .email(user.getEmail())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .heightCm(user.getHeightCm())
                .currentWeightKg(user.getCurrentWeightKg())
                .targetWeightKg(user.getTargetWeightKg())
                .dateJoined(user.getDateJoined())
                .fitnessLevel(user.getFitnessLevel())
                .profileImageUrl(user.getProfileImageUrl())
                .primaryGoal(user.getPrimaryGoal() != null 
                        ? goalMapper.toGoalResponse(user.getPrimaryGoal()) 
                        : null)
                .userPreference(toUserPreferenceResponse(user.getUserPreference()))
                .build();
    }

    private UserPreferenceResponse toUserPreferenceResponse(UserPreference pref) {
        if (pref == null) {
            return null;
        }
        return UserPreferenceResponse.builder()
                .preferenceId(pref.getPreferenceId())
                .preferredWorkoutDuration(pref.getPreferredWorkoutDuration())
                .preferredWorkoutTime(pref.getPreferredWorkoutTime())
                .allowAiSuggestions(pref.getAllowAiSuggestions())
                .notificationEnabled(pref.getNotificationEnabled())
                .measurementUnit(pref.getMeasurementUnit())
                .workoutReminderDays(pref.getWorkoutReminderDays())
                .dailyCalorieTarget(pref.getDailyCalorieTarget())
                .dailyProteinTargetG(pref.getDailyProteinTargetG())
                .dailyCarbsTargetG(pref.getDailyCarbsTargetG())
                .dailyFatsTargetG(pref.getDailyFatsTargetG())
                .build();
    }
}
