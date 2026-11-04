package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.UserMapper;
import com.dev.backend.model.dto.request.SetPrimaryGoalRequest;
import com.dev.backend.model.dto.response.UserProfileResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.User;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.GcpService;
import com.dev.backend.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final UserMapper userMapper;

    public UserServiceImpl(UserRepository userRepository, GoalRepository goalRepository,
                           UserMapper userMapper, GcpService gcpService) {
        this.userRepository = userRepository;
        this.goalRepository = goalRepository;
        this.userMapper = userMapper;
    }

    @Override
    public UserProfileResponse getCurrentUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        return userMapper.toUserProfileResponse(user);
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

        return userMapper.toUserProfileResponse(savedUser);
    }
}
