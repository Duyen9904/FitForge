package com.dev.backend.service;

import com.dev.backend.model.dto.request.UpdateUserPreferenceRequest;
import com.dev.backend.model.dto.response.UserPreferenceResponse;

public interface UserPreferenceService {

    /**
     * Get user preferences for the given user.
     * Creates default preferences if none exist.
     */
    UserPreferenceResponse getUserPreferences(Long userId);

    /**
     * Update user preferences. Only non-null fields in the request are applied.
     */
    UserPreferenceResponse updateUserPreferences(Long userId, UpdateUserPreferenceRequest request);
}
