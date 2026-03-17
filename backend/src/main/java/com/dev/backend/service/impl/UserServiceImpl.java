package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.UserMapper;
import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.MediaUploadResponse;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.enums.MediaCategory;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.GcpService;
import com.dev.backend.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);

    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final UserMapper userMapper;
    private final GcpService gcpService;

    public UserServiceImpl(UserRepository userRepository, GoalRepository goalRepository,
                           UserMapper userMapper, GcpService gcpService) {
        this.userRepository = userRepository;
        this.goalRepository = goalRepository;
        this.userMapper = userMapper;
        this.gcpService = gcpService;
    }

    @Override
    public UserProfileResponse getCurrentUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        return toProfileWithSignedUrl(user);
    }

    @Override
    @Transactional
    public UserProfileResponse setPrimaryGoal(Long userId, SetPrimaryGoalRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        Goal goal = goalRepository.findById(request.getGoalId())
                .orElseThrow(() -> new ResourceNotFoundException("Goal not found with id: " + request.getGoalId()));

        user.setPrimaryGoal(goal);
        User savedUser = userRepository.save(user);

        return toProfileWithSignedUrl(savedUser);
    }

    @Override
    @Transactional
    public UserProfileResponse uploadAvatar(Long userId, MultipartFile file) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Delete old avatar from GCS if present
        String oldPath = user.getProfileImageUrl();
        if (oldPath != null && !oldPath.isBlank()) {
            try {
                gcpService.delete(oldPath);
                log.info("Deleted old avatar for user {}: {}", userId, oldPath);
            } catch (Exception e) {
                log.warn("Failed to delete old avatar for user {}: {}", userId, e.getMessage());
            }
        }

        // Upload new avatar to GCS
        MediaUploadResponse uploadResponse = gcpService.upload(file, MediaCategory.PROFILE_AVATAR, userId);

        // Save the GCS object path on the user entity
        user.setProfileImageUrl(uploadResponse.getObjectPath());
        User savedUser = userRepository.save(user);

        log.info("Uploaded avatar for user {}: {}", userId, uploadResponse.getObjectPath());
        return toProfileWithSignedUrl(savedUser);
    }

    // ==================== Private Helpers ====================

    /**
     * Convert User to UserProfileResponse, resolving profileImageUrl to a signed URL.
     */
    private UserProfileResponse toProfileWithSignedUrl(User user) {
        UserProfileResponse response = userMapper.toUserProfileResponse(user);

        // Resolve GCS object path to a time-limited signed URL
        if (user.getProfileImageUrl() != null && !user.getProfileImageUrl().isBlank()) {
            try {
                response.setProfileImageUrl(gcpService.getSignedUrl(user.getProfileImageUrl()));
            } catch (Exception e) {
                log.warn("Failed to generate signed URL for avatar: {}", e.getMessage());
                // Keep the raw object path as fallback
            }
        }

        return response;
    }
}
