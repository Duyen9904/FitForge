package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.OnboardingMapper;
import com.dev.backend.model.dto.onboarding.OnboardingStepConfig;
import com.dev.backend.model.dto.onboarding.OnboardingStepConfig.OnboardingOptionItem;
import com.dev.backend.model.dto.request.ReorderOnboardingStepsRequest;
import com.dev.backend.model.dto.request.SaveOnboardingOptionRequest;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingAnalyticsResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.entity.OnboardingFlow;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStatus;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingFlowRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingRepository;
import com.dev.backend.repository.UserOnboardingStepRepository;
import com.dev.backend.service.OnboardingAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OnboardingAdminServiceImpl implements OnboardingAdminService {

    private final OnboardingFlowRepository flowRepository;
    private final OnboardingStepRepository stepRepository;
    private final UserOnboardingRepository userOnboardingRepository;
    private final UserOnboardingStepRepository userOnboardingStepRepository;
    private final GoalRepository goalRepository;
    private final OnboardingMapper onboardingMapper;

    // ============= Step Management =============

    @Override
    @Transactional(readOnly = true)
    public List<OnboardingStepResponse> getAllSteps() {
        Optional<OnboardingFlow> activeFlow = flowRepository.findFirstByIsActiveTrueOrderByVersionDesc();
        List<OnboardingStep> steps = activeFlow.isPresent()
                ? stepRepository.findByFlowIdOrderBySequenceAsc(activeFlow.get().getId())
                : stepRepository.findAllByOrderBySequenceAsc();

        return steps.stream()
                .map(onboardingMapper::toStepResponseWithAllOptions)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public OnboardingStepResponse createStep(SaveOnboardingStepRequest request) {
        OnboardingFlow flow = getOrCreateDefaultFlow();

        if (stepRepository.existsByFlowIdAndStepKey(flow.getId(), request.getStepKey())) {
            throw new IllegalArgumentException("Step key already exists: " + request.getStepKey());
        }

        Integer sequence = request.getDisplayOrder();
        if (sequence == null) {
            sequence = stepRepository.findTopByFlowIdOrderBySequenceDesc(flow.getId())
                    .map(s -> s.getSequence() + 1)
                    .orElse(1);
        }

        OnboardingInputType inputType = request.getInputType() != null
                ? request.getInputType()
                : defaultInputTypeFor(request.getStepType());

        OnboardingStepConfig config = OnboardingStepConfig.builder()
                .subtitle(request.getSubtitle())
                .helpText(request.getHelpText())
                .stepType(request.getStepType())
                .inputType(inputType)
                .iconUrl(request.getIconUrl())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .options(new ArrayList<>())
                .build();

        OnboardingStep step = new OnboardingStep();
        step.setFlow(flow);
        step.setStepKey(request.getStepKey());
        step.setTitle(request.getTitle());
        step.setSequence(sequence);
        step.setIsRequired(request.getIsRequired() != null ? request.getIsRequired() : true);
        step.setParsedConfig(config);

        step = stepRepository.save(step);
        return onboardingMapper.toStepResponseWithAllOptions(step);
    }

    @Override
    @Transactional
    public OnboardingStepResponse updateStep(Long stepId, SaveOnboardingStepRequest request) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));

        Long flowId = step.getFlow() != null ? step.getFlow().getId() : getOrCreateDefaultFlow().getId();

        if (!step.getStepKey().equals(request.getStepKey()) &&
            stepRepository.existsByFlowIdAndStepKey(flowId, request.getStepKey())) {
            throw new IllegalArgumentException("Step key already exists: " + request.getStepKey());
        }

        OnboardingStepConfig config = step.getParsedConfig();
        config.setSubtitle(request.getSubtitle());
        config.setHelpText(request.getHelpText());
        config.setStepType(request.getStepType());
        if (request.getInputType() != null) {
            config.setInputType(request.getInputType());
        } else if (config.getInputType() == null) {
            config.setInputType(defaultInputTypeFor(request.getStepType()));
        }
        if (request.getIsActive() != null) {
            config.setIsActive(request.getIsActive());
        }
        config.setIconUrl(request.getIconUrl());

        step.setStepKey(request.getStepKey());
        step.setTitle(request.getTitle());
        if (request.getDisplayOrder() != null) {
            step.setSequence(request.getDisplayOrder());
        }
        if (request.getIsRequired() != null) {
            step.setIsRequired(request.getIsRequired());
        }
        step.setParsedConfig(config);

        step = stepRepository.save(step);
        return onboardingMapper.toStepResponseWithAllOptions(step);
    }

    @Override
    @Transactional
    public void deleteStep(Long stepId) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));

        long userDataCount = userOnboardingStepRepository.countByStepIdAndStatus(stepId, OnboardingStepStatus.COMPLETED);
        if (userDataCount > 0) {
            throw new IllegalStateException("Cannot delete step with existing user data. Consider deactivating instead.");
        }

        stepRepository.delete(step);
    }

    @Override
    @Transactional
    public void reorderSteps(ReorderOnboardingStepsRequest request) {
        List<Long> stepIds = request.getStepIds();

        for (int i = 0; i < stepIds.size(); i++) {
            OnboardingStep step = stepRepository.findById(stepIds.get(i))
                    .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found"));
            step.setSequence(i + 1);
            stepRepository.save(step);
        }
    }

    // ============= Option Management (Stored in step.config JSON) =============

    @Override
    @Transactional
    public OnboardingOptionResponse createOption(Long stepId, SaveOnboardingOptionRequest request) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));

        OnboardingStepConfig config = step.getParsedConfig();
        List<OnboardingOptionItem> options = config.getOptions() != null
                ? new ArrayList<>(config.getOptions())
                : new ArrayList<>();

        boolean keyExists = options.stream()
                .anyMatch(o -> o.getOptionKey() != null && o.getOptionKey().equals(request.getOptionKey()));
        if (keyExists) {
            throw new IllegalArgumentException("Option key already exists for this step: " + request.getOptionKey());
        }

        Integer displayOrder = request.getDisplayOrder();
        if (displayOrder == null) {
            displayOrder = options.stream()
                    .map(OnboardingOptionItem::getDisplayOrder)
                    .filter(Objects::nonNull)
                    .max(Integer::compareTo)
                    .map(max -> max + 1)
                    .orElse(1);
        }

        Long goalId = null;
        if (request.getGoalId() != null) {
            Goal goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal not found: " + request.getGoalId()));
            goalId = goal.getGoalId();
        }

        Long nextOptionId = generateNextOptionId();

        OnboardingOptionItem newItem = OnboardingOptionItem.builder()
                .optionId(nextOptionId)
                .optionKey(request.getOptionKey())
                .label(request.getLabel())
                .description(request.getDescription())
                .iconUrl(request.getIconUrl())
                .displayOrder(displayOrder)
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .metadata(request.getMetadata())
                .goalId(goalId)
                .build();

        options.add(newItem);
        config.setOptions(options);
        step.setParsedConfig(config);
        stepRepository.save(step);

        return onboardingMapper.toOptionResponse(newItem);
    }

    @Override
    @Transactional
    public OnboardingOptionResponse updateOption(Long optionId, SaveOnboardingOptionRequest request) {
        List<OnboardingStep> allSteps = stepRepository.findAllByOrderBySequenceAsc();

        for (OnboardingStep step : allSteps) {
            OnboardingStepConfig config = step.getParsedConfig();
            if (config.getOptions() == null) {
                continue;
            }
            List<OnboardingOptionItem> options = new ArrayList<>(config.getOptions());
            Optional<OnboardingOptionItem> targetOpt = options.stream()
                    .filter(o -> Objects.equals(o.getOptionId(), optionId))
                    .findFirst();

            if (targetOpt.isPresent()) {
                OnboardingOptionItem option = targetOpt.get();

                if (!Objects.equals(option.getOptionKey(), request.getOptionKey())) {
                    boolean duplicateKey = options.stream()
                            .anyMatch(o -> !Objects.equals(o.getOptionId(), optionId)
                                    && Objects.equals(o.getOptionKey(), request.getOptionKey()));
                    if (duplicateKey) {
                        throw new IllegalArgumentException("Option key already exists for this step: " + request.getOptionKey());
                    }
                }

                option.setOptionKey(request.getOptionKey());
                option.setLabel(request.getLabel());
                option.setDescription(request.getDescription());
                option.setIconUrl(request.getIconUrl());
                if (request.getDisplayOrder() != null) {
                    option.setDisplayOrder(request.getDisplayOrder());
                }
                if (request.getIsActive() != null) {
                    option.setIsActive(request.getIsActive());
                }
                option.setMetadata(request.getMetadata());

                if (request.getGoalId() != null) {
                    Goal goal = goalRepository.findById(request.getGoalId())
                            .orElseThrow(() -> new ResourceNotFoundException("Goal not found: " + request.getGoalId()));
                    option.setGoalId(goal.getGoalId());
                } else {
                    option.setGoalId(null);
                }

                config.setOptions(options);
                step.setParsedConfig(config);
                stepRepository.save(step);

                return onboardingMapper.toOptionResponse(option);
            }
        }

        throw new ResourceNotFoundException("Onboarding option not found: " + optionId);
    }

    @Override
    @Transactional
    public void deleteOption(Long optionId) {
        List<OnboardingStep> allSteps = stepRepository.findAllByOrderBySequenceAsc();

        for (OnboardingStep step : allSteps) {
            OnboardingStepConfig config = step.getParsedConfig();
            if (config.getOptions() == null) {
                continue;
            }
            List<OnboardingOptionItem> options = new ArrayList<>(config.getOptions());
            boolean removed = options.removeIf(o -> Objects.equals(o.getOptionId(), optionId));
            if (removed) {
                config.setOptions(options);
                step.setParsedConfig(config);
                stepRepository.save(step);
                return;
            }
        }

        throw new ResourceNotFoundException("Onboarding option not found: " + optionId);
    }

    // ============= Analytics =============

    @Override
    @Transactional(readOnly = true)
    public OnboardingAnalyticsResponse getOnboardingAnalytics(LocalDate from, LocalDate to) {
        LocalDateTime fromDateTime = from.atStartOfDay();
        LocalDateTime toDateTime = to.atTime(LocalTime.MAX);

        long completedSessions = userOnboardingRepository.countByStatusAndCompletedAtBetween(
                OnboardingStatus.COMPLETED, fromDateTime, toDateTime);
        long completedUsersFromSteps = userOnboardingStepRepository.countUsersCompletedBetween(
                fromDateTime, toDateTime);
        long completedCount = Math.max(completedSessions, completedUsersFromSteps);

        Map<Long, Long> completionsByStep = new HashMap<>();
        Map<Long, Long> skipsByStep = new HashMap<>();

        List<Object[]> completionStats = userOnboardingStepRepository.countByStepAndStatus(OnboardingStepStatus.COMPLETED);
        for (Object[] stat : completionStats) {
            completionsByStep.put((Long) stat[0], (Long) stat[1]);
        }

        List<Object[]> skipStats = userOnboardingStepRepository.countByStepAndStatus(OnboardingStepStatus.SKIPPED);
        for (Object[] stat : skipStats) {
            skipsByStep.put((Long) stat[0], (Long) stat[1]);
        }

        long startedSessions = userOnboardingRepository.countByStartedAtBetween(fromDateTime, toDateTime);
        long maxStepCompletions = completionsByStep.values().stream().max(Long::compareTo).orElse(0L);
        long totalStarted = Math.max(startedSessions, maxStepCompletions);

        double completionRate = totalStarted > 0 ? (double) completedCount / totalStarted : 0.0;

        return OnboardingAnalyticsResponse.builder()
                .totalUsersStarted(totalStarted)
                .totalUsersCompleted(completedCount)
                .completionRate(completionRate)
                .completionsByStep(completionsByStep)
                .skipsByStep(skipsByStep)
                .popularOptionsByStep(new HashMap<>())
                .build();
    }

    private OnboardingFlow getOrCreateDefaultFlow() {
        return flowRepository.findFirstByIsActiveTrueOrderByVersionDesc()
                .orElseGet(() -> {
                    OnboardingFlow flow = new OnboardingFlow();
                    flow.setFlowKey("default_onboarding");
                    flow.setName("Default User Onboarding");
                    flow.setVersion(1);
                    flow.setIsActive(true);
                    return flowRepository.save(flow);
                });
    }

    private Long generateNextOptionId() {
        return stepRepository.findAllByOrderBySequenceAsc().stream()
                .map(OnboardingStep::getParsedConfig)
                .filter(c -> c.getOptions() != null)
                .flatMap(c -> c.getOptions().stream())
                .map(OnboardingOptionItem::getOptionId)
                .filter(Objects::nonNull)
                .max(Long::compareTo)
                .map(max -> max + 1)
                .orElse(1L);
    }

    private OnboardingInputType defaultInputTypeFor(OnboardingStepType stepType) {
        if (stepType == null) {
            return OnboardingInputType.SINGLE_CHOICE;
        }
        return switch (stepType) {
            case PERSONAL_INFO -> OnboardingInputType.TEXT;
            case BODY_METRICS, AGE, WEIGHT, HEIGHT -> OnboardingInputType.NUMBER;
            case GENDER, FITNESS_LEVEL -> OnboardingInputType.SINGLE_CHOICE;
            case FITNESS_GOAL, EQUIPMENT, SCHEDULE, HEALTH_LIMITATIONS -> OnboardingInputType.MULTIPLE_CHOICE;
            case NOTIFICATIONS -> OnboardingInputType.TOGGLE;
        };
    }
}
