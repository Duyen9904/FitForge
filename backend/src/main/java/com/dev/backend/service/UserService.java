package com.dev.backend.service;

import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.UserProfileResponse;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {

    /**
     * Get current user's profile
     */
    UserProfileResponse getCurrentUserProfile(Long userId);

    /**
     * Set user's primary fitness goal (UC-12.2)
     */
    UserProfileResponse setPrimaryGoal(Long userId, SetPrimaryGoalRequest request);

    /**
     * Upload or replace user's avatar image.
     * Atomically uploads to GCS, deletes old avatar if present, and updates the user profile.
     */
    UserProfileResponse uploadAvatar(Long userId, MultipartFile file);
}
