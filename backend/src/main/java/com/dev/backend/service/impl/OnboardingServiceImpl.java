package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.OnboardingMapper;
import com.dev.backend.model.dto.onboarding.OnboardingStepConfig;
import com.dev.backend.model.dto.onboarding.OnboardingStepConfig.OnboardingOptionItem;
import com.dev.backend.model.dto.request.SubmitOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingProgressResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.OnboardingFlow;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.User;
import com.dev.backend.model.entity.UserOnboarding;
import com.dev.backend.model.entity.UserOnboardingStep;
import com.dev.backend.model.entity.UserOnboardingStepId;
import com.dev.backend.model.enums.OnboardingStatus;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingFlowRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingRepository;
import com.dev.backend.repository.UserOnboardingStepRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.OnboardingService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OnboardingServiceImpl implements OnboardingService {

    private final OnboardingFlowRepository flowRepository;
    private final OnboardingStepRepository stepRepository;
    private final UserOnboardingRepository userOnboardingRepository;
    private final UserOnboardingStepRepository userOnboardingStepRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;
    private final OnboardingMapper onboardingMapper;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public OnboardingFlowResponse getOnboardingFlow(Long userId) {
        Optional<UserOnboarding> existingOnboarding = userOnboardingRepository
                .findFirstByUserUserIdOrderByStartedAtDesc(userId);

        OnboardingFlow flow;
        UserOnboarding userOnboarding = null;

        if (existingOnboarding.isPresent()) {
            userOnboarding = existingOnboarding.get();
            flow = userOnboarding.getFlow();
        } else {
            flow = flowRepository.findFirstByIsActiveTrueOrderByVersionDesc().orElse(null);
            if (flow != null) {
                Optional<User> userOpt = userRepository.findById(userId);
                if (userOpt.isPresent()) {
                    List<OnboardingStep> flowSteps = getActiveSteps(flow);
                    UserOnboarding newOnboarding = new UserOnboarding();
                    newOnboarding.setUser(userOpt.get());
                    newOnboarding.setFlow(flow);
                    newOnboarding.setStatus(OnboardingStatus.IN_PROGRESS);
                    newOnboarding.setStartedAt(LocalDateTime.now());
                    if (!flowSteps.isEmpty()) {
                        newOnboarding.setCurrentStep(flowSteps.get(0));
                    }
                    userOnboarding = userOnboardingRepository.save(newOnboarding);
                }
            }
        }

        List<OnboardingStep> steps = getActiveSteps(flow);
        Map<Long, UserOnboardingStep> progressMap;

        if (userOnboarding != null && userOnboarding.getId() != null) {
            progressMap = userOnboardingStepRepository.findByOnboardingId(userOnboarding.getId())
                    .stream()
                    .collect(Collectors.toMap(s -> s.getStep().getId(), s -> s, (a, b) -> b));
        } else {
            progressMap = userOnboardingStepRepository.findByOnboardingUserUserId(userId)
                    .stream()
                    .collect(Collectors.toMap(s -> s.getStep().getId(), s -> s, (a, b) -> b));
        }

        return onboardingMapper.toFlowResponse(steps, progressMap);
    }

    @Override
    @Transactional
    public OnboardingProgressResponse submitStepResponse(Long userId, Long stepId, SubmitOnboardingStepRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));

        UserOnboarding userOnboarding = getOrCreateUserOnboarding(user, step.getFlow());
        LocalDateTime now = LocalDateTime.now();

        UserOnboardingStep progress = userOnboardingStepRepository
                .findByOnboardingIdAndStepId(userOnboarding.getId(), stepId)
                .orElseGet(() -> {
                    UserOnboardingStep newStep = new UserOnboardingStep();
                    newStep.setId(new UserOnboardingStepId(userOnboarding.getId(), step.getId()));
                    newStep.setOnboarding(userOnboarding);
                    newStep.setStep(step);
                    newStep.setStartedAt(now);
                    return newStep;
                });

        progress.setStatus(OnboardingStepStatus.COMPLETED);
        progress.setAnswerData(request.getResponseData());
        progress.setCompletedAt(now);
        progress.setUpdatedAt(now);

        userOnboardingStepRepository.save(progress);

        // Apply the response data to the user profile based on step config
        applyResponseToUserProfile(user, step, request.getResponseData());
        userRepository.save(user);

        return buildAndUpdateProgressResponse(userOnboarding, step);
    }

    @Override
    @Transactional
    public OnboardingProgressResponse skipStep(Long userId, Long stepId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));

        if (Boolean.TRUE.equals(step.getIsRequired())) {
            throw new IllegalStateException("Cannot skip required step: " + step.getStepKey());
        }

        UserOnboarding userOnboarding = getOrCreateUserOnboarding(user, step.getFlow());
        LocalDateTime now = LocalDateTime.now();

        UserOnboardingStep progress = userOnboardingStepRepository
                .findByOnboardingIdAndStepId(userOnboarding.getId(), stepId)
                .orElseGet(() -> {
                    UserOnboardingStep newStep = new UserOnboardingStep();
                    newStep.setId(new UserOnboardingStepId(userOnboarding.getId(), step.getId()));
                    newStep.setOnboarding(userOnboarding);
                    newStep.setStep(step);
                    newStep.setStartedAt(now);
                    return newStep;
                });

        progress.setStatus(OnboardingStepStatus.SKIPPED);
        progress.setCompletedAt(now);
        progress.setUpdatedAt(now);

        userOnboardingStepRepository.save(progress);

        return buildAndUpdateProgressResponse(userOnboarding, step);
    }

    @Override
    @Transactional
    public void completeOnboarding(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        OnboardingFlow activeFlow = flowRepository.findFirstByIsActiveTrueOrderByVersionDesc().orElse(null);
        UserOnboarding userOnboarding = userOnboardingRepository
                .findFirstByUserUserIdOrderByStartedAtDesc(userId)
                .orElseGet(() -> activeFlow != null ? getOrCreateUserOnboarding(user, activeFlow) : null);

        OnboardingFlow flowToVerify = userOnboarding != null ? userOnboarding.getFlow() : activeFlow;
        List<OnboardingStep> requiredSteps = getActiveSteps(flowToVerify).stream()
                .filter(s -> Boolean.TRUE.equals(s.getIsRequired()))
                .collect(Collectors.toList());

        for (OnboardingStep step : requiredSteps) {
            boolean isComplete = userOnboarding != null
                    && userOnboardingStepRepository.existsByOnboardingIdAndStepIdAndStatus(
                            userOnboarding.getId(), step.getId(), OnboardingStepStatus.COMPLETED);
            if (!isComplete) {
                throw new IllegalStateException("Cannot complete onboarding. Required step not completed: " + step.getStepKey());
            }
        }

        if (userOnboarding != null) {
            userOnboarding.setStatus(OnboardingStatus.COMPLETED);
            userOnboarding.setCompletedAt(LocalDateTime.now());
            userOnboarding.setCurrentStep(null);
            userOnboardingRepository.save(userOnboarding);
        }

        user.setOnboardingCompleted(true);
        userRepository.save(user);
    }

    private UserOnboarding getOrCreateUserOnboarding(User user, OnboardingFlow stepFlow) {
        OnboardingFlow flow = stepFlow != null
                ? stepFlow
                : flowRepository.findFirstByIsActiveTrueOrderByVersionDesc()
                        .orElseThrow(() -> new IllegalStateException("No active onboarding flow configured"));

        return userOnboardingRepository.findByUserUserIdAndFlowId(user.getUserId(), flow.getId())
                .orElseGet(() -> {
                    UserOnboarding newOnboarding = new UserOnboarding();
                    newOnboarding.setUser(user);
                    newOnboarding.setFlow(flow);
                    newOnboarding.setStatus(OnboardingStatus.IN_PROGRESS);
                    newOnboarding.setStartedAt(LocalDateTime.now());
                    return userOnboardingRepository.save(newOnboarding);
                });
    }

    private List<OnboardingStep> getActiveSteps(OnboardingFlow flow) {
        List<OnboardingStep> rawSteps;
        if (flow != null && flow.getId() != null) {
            rawSteps = stepRepository.findByFlowIdOrderBySequenceAsc(flow.getId());
        } else {
            rawSteps = stepRepository.findAllByOrderBySequenceAsc();
        }
        if (rawSteps == null) {
            return Collections.emptyList();
        }
        return rawSteps.stream()
                .filter(s -> {
                    OnboardingStepConfig cfg = s.getParsedConfig();
                    return cfg.getIsActive() == null || Boolean.TRUE.equals(cfg.getIsActive());
                })
                .collect(Collectors.toList());
    }

    private OnboardingProgressResponse buildAndUpdateProgressResponse(
            UserOnboarding userOnboarding, OnboardingStep currentStep) {
        List<OnboardingStep> steps = getActiveSteps(userOnboarding.getFlow());
        List<UserOnboardingStep> progressList = userOnboardingStepRepository
                .findByOnboardingId(userOnboarding.getId());
        Map<Long, UserOnboardingStep> progressMap = progressList.stream()
                .collect(Collectors.toMap(p -> p.getStep().getId(), p -> p, (a, b) -> b));

        OnboardingStep nextStep = null;
        boolean allRequiredComplete = true;

        for (OnboardingStep step : steps) {
            UserOnboardingStep progress = progressMap.get(step.getId());
            boolean isComplete = progress != null &&
                    (progress.getStatus() == OnboardingStepStatus.COMPLETED ||
                     progress.getStatus() == OnboardingStepStatus.SKIPPED);

            if (!isComplete) {
                if (nextStep == null) {
                    nextStep = step;
                }
                if (Boolean.TRUE.equals(step.getIsRequired())) {
                    allRequiredComplete = false;
                }
            }
        }

        userOnboarding.setCurrentStep(nextStep);
        userOnboardingRepository.save(userOnboarding);

        UserOnboardingStep currentProgress = progressMap.get(currentStep.getId());
        OnboardingStepConfig cfg = currentStep.getParsedConfig();

        return OnboardingProgressResponse.builder()
                .stepId(currentStep.getId())
                .stepKey(currentStep.getStepKey())
                .inputType(cfg.getInputType())
                .status(currentProgress != null ? currentProgress.getStatus() : OnboardingStepStatus.PENDING)
                .responseData(currentProgress != null ? currentProgress.getAnswerData() : null)
                .completedAt(currentProgress != null ? currentProgress.getCompletedAt() : null)
                .nextStepId(nextStep != null ? nextStep.getId() : null)
                .onboardingComplete(allRequiredComplete)
                .build();
    }

    /**
     * Apply the step response data to the user's profile.
     */
    private void applyResponseToUserProfile(User user, OnboardingStep step, String responseData) {
        if (responseData == null || responseData.isBlank()) {
            log.warn("No response data provided for user {} step {}", user.getUserId(), step.getStepKey());
            return;
        }

        try {
            JsonNode root = objectMapper.readTree(responseData);
            OnboardingStepConfig cfg = step.getParsedConfig();
            OnboardingStepType stepType = cfg.getStepType();

            if (stepType == null) {
                log.warn("No stepType configured in config JSON for step {}", step.getStepKey());
                return;
            }

            log.info("Applying onboarding response for user {}, stepType: {}, responseData: {}",
                    user.getUserId(), stepType, responseData);

            switch (stepType) {
                case PERSONAL_INFO -> applyPersonalInfo(user, root);
                case BODY_METRICS -> applyBodyMetrics(user, root);
                case GENDER -> applyGender(user, root);
                case AGE -> applyAge(user, root);
                case WEIGHT -> applyWeight(user, root);
                case HEIGHT -> applyHeight(user, root);
                case FITNESS_LEVEL -> applyFitnessLevel(user, root);
                case FITNESS_GOAL -> applyFitnessGoal(user, step, root);
                case EQUIPMENT, SCHEDULE, HEALTH_LIMITATIONS, NOTIFICATIONS -> {
                    log.debug("Step {} data stored in user_onboarding_steps.answer_data", stepType);
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

    private void applyGender(User user, JsonNode root) {
        if (root.has("selected")) {
            user.setGender(root.get("selected").asText().toUpperCase());
        } else if (root.has("gender")) {
            user.setGender(root.get("gender").asText().toUpperCase());
        }
    }

    private void applyAge(User user, JsonNode root) {
        if (root.has("value")) {
            int age = root.get("value").asInt();
            user.setDateOfBirth(LocalDate.now().minusYears(age));
        } else if (root.has("age")) {
            int age = root.get("age").asInt();
            user.setDateOfBirth(LocalDate.now().minusYears(age));
        }
    }

    private void applyWeight(User user, JsonNode root) {
        if (root.has("value")) {
            user.setCurrentWeightKg((float) root.get("value").asDouble());
        } else if (root.has("weight")) {
            user.setCurrentWeightKg((float) root.get("weight").asDouble());
        }
    }

    private void applyHeight(User user, JsonNode root) {
        if (root.has("value")) {
            user.setHeightCm((float) root.get("value").asDouble());
        } else if (root.has("height")) {
            user.setHeightCm((float) root.get("height").asDouble());
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

    private void applyFitnessGoal(User user, OnboardingStep step, JsonNode root) {
        Long optionId = null;

        log.debug("Parsing fitness goal from JSON for user {}: {}", user.getUserId(), root.toString());

        if (root.has("optionId")) {
            optionId = root.get("optionId").asLong();
        } else if (root.has("selected")) {
            JsonNode selected = root.get("selected");
            if (selected.isArray() && selected.size() > 0) {
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

        if (optionId != null) {
            final Long targetOptionId = optionId;
            OnboardingStepConfig cfg = step.getParsedConfig();
            Optional<OnboardingOptionItem> matchedOption = cfg.getOptions() != null
                    ? cfg.getOptions().stream()
                            .filter(o -> targetOptionId.equals(o.getOptionId()))
                            .findFirst()
                    : Optional.empty();

            if (matchedOption.isPresent() && matchedOption.get().getGoalId() != null) {
                Long goalId = matchedOption.get().getGoalId();
                Optional<Goal> goalOpt = goalRepository.findById(goalId);
                if (goalOpt.isPresent()) {
                    Goal goal = goalOpt.get();
                    user.setPrimaryGoal(goal);
                    log.info("Successfully set primary goal for user {} from option {}: {} (ID: {})",
                            user.getUserId(), optionId, goal.getGoalName(), goal.getGoalId());
                    return;
                }
            }
            log.warn("Option {} had no linked goal in step config for user {}. Falling back to legacy matching.",
                    optionId, user.getUserId());
        } else {
            log.warn("No optionId found in fitness goal response for user {}. Falling back to legacy string matching.",
                    user.getUserId());
        }

        applyFitnessGoalLegacy(user, step, root);
    }

    private void applyFitnessGoalLegacy(User user, OnboardingStep step, JsonNode root) {
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
        } else if (root.has("selectedOptions") && root.get("selectedOptions").isArray() && root.get("selectedOptions").size() > 0) {
            goalName = root.get("selectedOptions").get(0).asText();
        } else if (root.has("goalName")) {
            goalName = root.get("goalName").asText();
        } else if (root.has("name")) {
            goalName = root.get("name").asText();
        }

        Optional<Goal> goalOpt = Optional.empty();

        if (goalId != null) {
            goalOpt = goalRepository.findById(goalId);
        }

        if (goalOpt.isEmpty() && goalName != null && !goalName.isBlank()) {
            // Also check if goalName matches an optionKey or label in step config with a goalId
            final String targetKey = goalName;
            OnboardingStepConfig cfg = step.getParsedConfig();
            if (cfg.getOptions() != null) {
                Optional<OnboardingOptionItem> byKey = cfg.getOptions().stream()
                        .filter(o -> targetKey.equalsIgnoreCase(o.getOptionKey()) || targetKey.equalsIgnoreCase(o.getLabel()))
                        .findFirst();
                if (byKey.isPresent() && byKey.get().getGoalId() != null) {
                    goalOpt = goalRepository.findById(byKey.get().getGoalId());
                }
            }
            if (goalOpt.isEmpty()) {
                goalOpt = goalRepository.findByGoalName(goalName);
            }
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
