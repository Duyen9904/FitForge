package com.dev.backend.service;

import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.UserProfileResponse;

public interface UserService {

    /**
     * Get current user's profile
     */
    UserProfileResponse getCurrentUserProfile(Long userId);

    /**
     * Set user's primary fitness goal (UC-12.2)
     */
    UserProfileResponse setPrimaryGoal(Long userId, SetPrimaryGoalRequest request);
}
