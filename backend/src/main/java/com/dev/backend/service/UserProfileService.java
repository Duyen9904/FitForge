package com.dev.backend.service;

import com.dev.backend.model.dto.profile.UserProfile;

/**
 * Builds a read-only {@link UserProfile} view from onboarding
 * responses, user core fields, and preferences.
 *
 * This abstraction keeps recommendation services decoupled
 * from the underlying onboarding storage model.
 */
public interface UserProfileService {

    /**
     * Build a {@link UserProfile} for the given user.
     * Throws if the user does not exist.
     */
    UserProfile buildProfile(Long userId);
}

