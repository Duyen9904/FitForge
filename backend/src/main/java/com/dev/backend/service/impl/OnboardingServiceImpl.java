package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.OnboardingMapper;
import com.dev.backend.model.dto.request.SubmitOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingProgressResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.OnboardingOption;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingOptionRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingProgressRepository;
import com.dev.backend.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.dev.backend.service.OnboardingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OnboardingServiceImpl implements OnboardingService {

    private final OnboardingStepRepository stepRepository;
    private final UserOnboardingProgressRepository progressRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final OnboardingOptionRepository onboardingOptionRepository;
    private final OnboardingMapper onboardingMapper;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional(readOnly = true)
    public OnboardingFlowResponse getOnboardingFlow(Long userId) {
        // Get all active steps
        List<OnboardingStep> steps = stepRepository.findByIsActiveTrueOrderByDisplayOrderAsc();
        
        // Get user's progress
        List<UserOnboardingProgress> progressList = progressRepository.findByUserUserId(userId);
        Map<Long, UserOnboardingProgress> progressMap = progressList.stream()
                .collect(Collectors.toMap(p -> p.getStep().getStepId(), p -> p));
        
        return onboardingMapper.toFlowResponse(steps, progressMap);
    }

    @Override
    @Transactional
    public OnboardingProgressResponse submitStepResponse(Long userId, Long stepId, SubmitOnboardingStepRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));
        
        // Find or create progress record
        UserOnboardingProgress progress = progressRepository
                .findByUserUserIdAndStepStepId(userId, stepId)
                .orElseGet(() -> {
                    UserOnboardingProgress newProgress = new UserOnboardingProgress();
                    newProgress.setUser(user);
                    newProgress.setStep(step);
                    return newProgress;
                });
        
        // Update progress
        progress.setStatus(OnboardingStepStatus.COMPLETED);
        progress.setResponseData(request.getResponseData());
        progress.setCompletedAt(LocalDateTime.now());
        
        progressRepository.save(progress);
        
        // Apply the response data to the user profile based on step type
        applyResponseToUserProfile(user, step, request.getResponseData());
        userRepository.save(user);
        
        return buildProgressResponse(userId, step);
    }

    @Override
    @Transactional
    public OnboardingProgressResponse skipStep(Long userId, Long stepId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));
        
        if (step.getIsRequired()) {
            throw new IllegalStateException("Cannot skip required step: " + step.getStepKey());
        }
        
        // Find or create progress record
        UserOnboardingProgress progress = progressRepository
                .findByUserUserIdAndStepStepId(userId, stepId)
                .orElseGet(() -> {
                    UserOnboardingProgress newProgress = new UserOnboardingProgress();
                    newProgress.setUser(user);
                    newProgress.setStep(step);
                    return newProgress;
                });
        
        // Mark as skipped
        progress.setStatus(OnboardingStepStatus.SKIPPED);
        progress.setCompletedAt(LocalDateTime.now());
        
        progressRepository.save(progress);
        
        return buildProgressResponse(userId, step);
    }

    @Override
    @Transactional
    public void completeOnboarding(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        
        // Verify all required steps are complete
        List<OnboardingStep> requiredSteps = stepRepository.findByIsActiveTrueOrderByDisplayOrderAsc()
                .stream()
                .filter(OnboardingStep::getIsRequired)
                .collect(Collectors.toList());
        
        for (OnboardingStep step : requiredSteps) {
            boolean isComplete = progressRepository.existsByUserUserIdAndStepStepIdAndStatus(
                    userId, step.getStepId(), OnboardingStepStatus.COMPLETED);
            if (!isComplete) {
                throw new IllegalStateException("Cannot complete onboarding. Required step not completed: " + step.getStepKey());
            }
        }
        
        user.setOnboardingCompleted(true);
        userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isOnboardingComplete(Long userId) {
        return userRepository.findById(userId)
                .map(User::getOnboardingCompleted)
                .orElse(false);
    }

    private OnboardingProgressResponse buildProgressResponse(Long userId, OnboardingStep currentStep) {
        // Find next pending step
        List<OnboardingStep> steps = stepRepository.findByIsActiveTrueOrderByDisplayOrderAsc();
        List<UserOnboardingProgress> progressList = progressRepository.findByUserUserId(userId);
        Map<Long, UserOnboardingProgress> progressMap = progressList.stream()
                .collect(Collectors.toMap(p -> p.getStep().getStepId(), p -> p));
        
        Long nextStepId = null;
        boolean allRequiredComplete = true;
        
        for (OnboardingStep step : steps) {
            UserOnboardingProgress progress = progressMap.get(step.getStepId());
            boolean isComplete = progress != null && 
                    (progress.getStatus() == OnboardingStepStatus.COMPLETED || 
                     progress.getStatus() == OnboardingStepStatus.SKIPPED);
            
            if (!isComplete) {
                if (nextStepId == null) {
                    nextStepId = step.getStepId();
                }
                if (step.getIsRequired()) {
                    allRequiredComplete = false;
                }
            }
        }
        
        UserOnboardingProgress currentProgress = progressMap.get(currentStep.getStepId());
        
        return OnboardingProgressResponse.builder()
                .stepId(currentStep.getStepId())
                .stepKey(currentStep.getStepKey())
                .inputType(currentStep.getStepType().getInputType())
                .status(currentProgress != null ? currentProgress.getStatus() : OnboardingStepStatus.PENDING)
                .responseData(currentProgress != null ? currentProgress.getResponseData() : null)
                .completedAt(currentProgress != null ? currentProgress.getCompletedAt() : null)
                .nextStepId(nextStepId)
                .onboardingComplete(allRequiredComplete)
                .build();
    }

    /**
     * Apply the step response data to the user's profile.
     * This is where we process JSON response and update user fields.
     */
    private void applyResponseToUserProfile(User user, OnboardingStep step, String responseData) {
        if (responseData == null || responseData.isBlank()) {
            log.warn("No response data provided for user {} step {}", user.getUserId(), step.getStepKey());
            return;
        }
        
        try {
            JsonNode root = objectMapper.readTree(responseData);
            OnboardingStepType stepType = step.getStepType();
            
            log.info("Applying onboarding response for user {}, stepType: {}, responseData: {}", 
                    user.getUserId(), stepType, responseData);
            
            switch (stepType) {
                case PERSONAL_INFO -> applyPersonalInfo(user, root);
                case BODY_METRICS -> applyBodyMetrics(user, root);
                case FITNESS_LEVEL -> applyFitnessLevel(user, root);
                case FITNESS_GOAL -> applyFitnessGoal(user, root);
                case EQUIPMENT, SCHEDULE, HEALTH_LIMITATIONS, NOTIFICATIONS -> {
                    // These steps update UserPreference, not User entity directly
                    // They are handled separately if needed
                    log.debug("Step {} data stored but not applied to User entity", stepType);
                }
            }
        } catch (Exception e) {
            log.error("Failed to parse onboarding response data for step {}: {}", step.getStepKey(), e.getMessage(), e);
        }
    }
    
    private void applyPersonalInfo(User user, JsonNode root) {
        if (root.has("dateOfBirth")) {
            String dobString = root.get("dateOfBirth").asText();
            try {
                user.setDateOfBirth(LocalDate.parse(dobString));
            } catch (Exception e) {
                log.warn("Failed to parse dateOfBirth: {}", dobString);
            }
        }
        if (root.has("gender")) {
            user.setGender(root.get("gender").asText());
        }
    }
    
    private void applyBodyMetrics(User user, JsonNode root) {
        if (root.has("weight")) {
            user.setCurrentWeightKg((float) root.get("weight").asDouble());
        }
        if (root.has("height")) {
            user.setHeightCm((float) root.get("height").asDouble());
        }
        if (root.has("targetWeight")) {
            user.setTargetWeightKg((float) root.get("targetWeight").asDouble());
        }
    }
    
    private void applyFitnessLevel(User user, JsonNode root) {
        // Handle both single value and selected option format
        String fitnessLevel = null;
        if (root.has("selected")) {
            fitnessLevel = root.get("selected").asText();
        } else if (root.has("fitnessLevel")) {
            fitnessLevel = root.get("fitnessLevel").asText();
        } else if (root.isTextual()) {
            fitnessLevel = root.asText();
        }
        
        if (fitnessLevel != null && !fitnessLevel.isBlank()) {
            user.setFitnessLevel(fitnessLevel);
        }
    }
    
    private void applyFitnessGoal(User user, JsonNode root) {
        // NEW APPROACH: Use optionId to get goal directly via FK relationship
        // This eliminates fragile string matching
        Long optionId = null;
        
        log.debug("Parsing fitness goal from JSON for user {}: {}", user.getUserId(), root.toString());
        
        // Extract selected option ID from various possible formats
        if (root.has("optionId")) {
            optionId = root.get("optionId").asLong();
        } else if (root.has("selected")) {
            JsonNode selected = root.get("selected");
            if (selected.isArray() && selected.size() > 0) {
                // For multiple choice, take the first selected option as primary
                JsonNode firstOption = selected.get(0);
                if (firstOption.isObject() && firstOption.has("optionId")) {
                    optionId = firstOption.get("optionId").asLong();
                } else if (firstOption.isNumber()) {
                    optionId = firstOption.asLong();
                }
            } else if (selected.isNumber()) {
                optionId = selected.asLong();
            }
        }
        
        // FALLBACK: Try old string-based approach for backwards compatibility
        if (optionId == null) {
            log.warn("No optionId found in fitness goal response for user {}. Falling back to legacy string matching.", user.getUserId());
            applyFitnessGoalLegacy(user, root);
            return;
        }
        
        log.info("Extracted option ID for user {}: optionId={}", user.getUserId(), optionId);
        
        // Look up option and get linked goal via FK
        Optional<OnboardingOption> optionOpt = onboardingOptionRepository.findById(optionId);
        if (optionOpt.isPresent() && optionOpt.get().getGoal() != null) {
            Goal goal = optionOpt.get().getGoal();
            user.setPrimaryGoal(goal);
            log.info("Successfully set primary goal for user {} from option {}: {} (ID: {})", 
                    user.getUserId(), optionId, goal.getGoalName(), goal.getGoalId());
        } else {
            if (optionOpt.isEmpty()) {
                log.warn("Option {} not found for user {}", optionId, user.getUserId());
            } else {
                log.warn("Option {} has no linked goal for user {}", optionId, user.getUserId());
            }
        }
    }
    
    /**
     * Legacy method for backwards compatibility with old string-based approach.
     * This supports old frontend implementations that send goal names instead of option IDs.
     */
    private void applyFitnessGoalLegacy(User user, JsonNode root) {
        String goalName = null;
        Long goalId = null;
        
        if (root.has("goalId")) {
            goalId = root.get("goalId").asLong();
        } else if (root.has("selected")) {
            JsonNode selected = root.get("selected");
            if (selected.isArray() && selected.size() > 0) {
                JsonNode firstGoal = selected.get(0);
                if (firstGoal.isObject()) {
                    if (firstGoal.has("goalId")) {
                        goalId = firstGoal.get("goalId").asLong();
                    } else if (firstGoal.has("id")) {
                        goalId = firstGoal.get("id").asLong();
                    } else if (firstGoal.has("name")) {
                        goalName = firstGoal.get("name").asText();
                    }
                } else if (firstGoal.isTextual()) {
                    goalName = firstGoal.asText();
                } else if (firstGoal.isNumber()) {
                    goalId = firstGoal.asLong();
                }
            } else if (selected.isTextual()) {
                goalName = selected.asText();
            } else if (selected.isNumber()) {
                goalId = selected.asLong();
            }
        } else if (root.has("goalName")) {
            goalName = root.get("goalName").asText();
        } else if (root.has("name")) {
            goalName = root.get("name").asText();
        }
        
        log.info("Extracted goal data (legacy) for user {}: goalId={}, goalName={}", user.getUserId(), goalId, goalName);
        
        Optional<Goal> goalOpt = Optional.empty();
        
        // Try to find goal by ID first, then by name
        if (goalId != null) {
            goalOpt = goalRepository.findById(goalId);
            log.debug("Looked up goal by ID {}: found={}", goalId, goalOpt.isPresent());
        }
        
        if (goalOpt.isEmpty() && goalName != null && !goalName.isBlank()) {
            goalOpt = goalRepository.findByGoalName(goalName);
            log.debug("Looked up goal by name '{}': found={}", goalName, goalOpt.isPresent());
        }
        
        if (goalOpt.isPresent()) {
            user.setPrimaryGoal(goalOpt.get());
            log.info("Successfully set primary goal for user {}: {} (ID: {})", 
                    user.getUserId(), goalOpt.get().getGoalName(), goalOpt.get().getGoalId());
        } else {
            log.warn("Could not find goal from response data. goalId={}, goalName={}. User {} will not have primaryGoal set.", 
                    goalId, goalName, user.getUserId());
        }
    }
}
