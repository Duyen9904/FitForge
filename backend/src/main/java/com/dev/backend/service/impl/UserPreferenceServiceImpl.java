package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.model.dto.request.UpdateUserPreferenceRequest;
import com.dev.backend.model.dto.response.UserPreferenceResponse;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserPreference;
import com.dev.backend.repository.UserPreferenceRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.UserPreferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserPreferenceServiceImpl implements UserPreferenceService {

    private final UserPreferenceRepository userPreferenceRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public UserPreferenceResponse getUserPreferences(Long userId) {
        UserPreference preference = getOrCreatePreference(userId);
        return toResponse(preference);
    }

    @Override
    @Transactional
    public UserPreferenceResponse updateUserPreferences(Long userId, UpdateUserPreferenceRequest request) {
        UserPreference preference = getOrCreatePreference(userId);

        if (request.getNotificationEnabled() != null) {
            preference.setNotificationEnabled(request.getNotificationEnabled());
        }
        if (request.getWorkoutReminderDays() != null) {
            preference.setWorkoutReminderDays(request.getWorkoutReminderDays());
        }
        if (request.getDailyCalorieTarget() != null) {
            preference.setDailyCalorieTarget(request.getDailyCalorieTarget());
        }
        if (request.getDailyProteinTargetG() != null) {
            preference.setDailyProteinTargetG(request.getDailyProteinTargetG());
        }
        if (request.getDailyCarbsTargetG() != null) {
            preference.setDailyCarbsTargetG(request.getDailyCarbsTargetG());
        }
        if (request.getDailyFatsTargetG() != null) {
            preference.setDailyFatsTargetG(request.getDailyFatsTargetG());
        }

        UserPreference saved = userPreferenceRepository.save(preference);
        return toResponse(saved);
    }

    private UserPreference getOrCreatePreference(Long userId) {
        return userPreferenceRepository.findByUserUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
                    UserPreference newPreference = new UserPreference();
                    newPreference.setUser(user);
                    return userPreferenceRepository.save(newPreference);
                });
    }

    private UserPreferenceResponse toResponse(UserPreference preference) {
        return UserPreferenceResponse.builder()
                .preferenceId(preference.getPreferenceId())
                .notificationEnabled(preference.getNotificationEnabled())
                .workoutReminderDays(preference.getWorkoutReminderDays())
                .dailyCalorieTarget(preference.getDailyCalorieTarget())
                .dailyProteinTargetG(preference.getDailyProteinTargetG())
                .dailyCarbsTargetG(preference.getDailyCarbsTargetG())
                .dailyFatsTargetG(preference.getDailyFatsTargetG())
                .build();
    }
}
