package com.dev.backend.service.impl;

import com.dev.backend.exception.ResourceNotFoundException;
import com.dev.backend.mapper.OnboardingMapper;
import com.dev.backend.model.dto.request.ReorderOnboardingStepsRequest;
import com.dev.backend.model.dto.request.SaveOnboardingOptionRequest;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingAnalyticsResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.OnboardingOption;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.Goal;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingOptionRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingProgressRepository;
import com.dev.backend.service.OnboardingAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OnboardingAdminServiceImpl implements OnboardingAdminService {

    private final OnboardingStepRepository stepRepository;
    private final OnboardingOptionRepository optionRepository;
    private final UserOnboardingProgressRepository progressRepository;
    private final GoalRepository goalRepository;
    private final OnboardingMapper onboardingMapper;

    // ============= Step Management =============

    @Override
    @Transactional(readOnly = true)
    public List<OnboardingStepResponse> getAllSteps() {
        return stepRepository.findAllByOrderByDisplayOrderAsc().stream()
                .map(onboardingMapper::toStepResponseWithAllOptions)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public OnboardingStepResponse createStep(SaveOnboardingStepRequest request) {
        // Check for duplicate step key
        if (stepRepository.existsByStepKey(request.getStepKey())) {
            throw new IllegalArgumentException("Step key already exists: " + request.getStepKey());
        }
        
        // Get next display order if not specified
        Integer displayOrder = request.getDisplayOrder();
        if (displayOrder == null) {
            displayOrder = stepRepository.findTopByOrderByDisplayOrderDesc()
                    .map(s -> s.getDisplayOrder() + 1)
                    .orElse(1);
        }
        
        OnboardingStep step = new OnboardingStep();
        step.setStepKey(request.getStepKey());
        step.setTitle(request.getTitle());
        step.setSubtitle(request.getSubtitle());
        step.setHelpText(request.getHelpText());
        step.setStepType(request.getStepType());
        step.setDisplayOrder(displayOrder);
        step.setIsRequired(request.getIsRequired() != null ? request.getIsRequired() : true);
        step.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
        step.setIconUrl(request.getIconUrl());
        
        step = stepRepository.save(step);
        return onboardingMapper.toStepResponseWithAllOptions(step);
    }

    @Override
    @Transactional
    public OnboardingStepResponse updateStep(Long stepId, SaveOnboardingStepRequest request) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));
        
        // Check for duplicate step key if it's being changed
        if (!step.getStepKey().equals(request.getStepKey()) && 
            stepRepository.existsByStepKey(request.getStepKey())) {
            throw new IllegalArgumentException("Step key already exists: " + request.getStepKey());
        }
        
        step.setStepKey(request.getStepKey());
        step.setTitle(request.getTitle());
        step.setSubtitle(request.getSubtitle());
        step.setHelpText(request.getHelpText());
        step.setStepType(request.getStepType());
        if (request.getDisplayOrder() != null) {
            step.setDisplayOrder(request.getDisplayOrder());
        }
        if (request.getIsRequired() != null) {
            step.setIsRequired(request.getIsRequired());
        }
        if (request.getIsActive() != null) {
            step.setIsActive(request.getIsActive());
        }
        step.setIconUrl(request.getIconUrl());
        
        step = stepRepository.save(step);
        return onboardingMapper.toStepResponseWithAllOptions(step);
    }

    @Override
    @Transactional
    public void deleteStep(Long stepId) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));
        
        // Check if step has user data
        long userDataCount = progressRepository.countByUserUserIdAndStatus(stepId, OnboardingStepStatus.COMPLETED);
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
            step.setDisplayOrder(i + 1);
            stepRepository.save(step);
        }
    }

    // ============= Option Management =============

    @Override
    @Transactional
    public OnboardingOptionResponse createOption(Long stepId, SaveOnboardingOptionRequest request) {
        OnboardingStep step = stepRepository.findById(stepId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding step not found: " + stepId));
        
        // Check for duplicate option key
        if (optionRepository.existsByStepStepIdAndOptionKey(stepId, request.getOptionKey())) {
            throw new IllegalArgumentException("Option key already exists for this step: " + request.getOptionKey());
        }
        
        // Get next display order
        Integer displayOrder = request.getDisplayOrder();
        if (displayOrder == null) {
            displayOrder = optionRepository.findTopByStepStepIdOrderByDisplayOrderDesc(stepId)
                    .map(o -> o.getDisplayOrder() + 1)
                    .orElse(1);
        }
        
        OnboardingOption option = new OnboardingOption();
        option.setStep(step);
        option.setOptionKey(request.getOptionKey());
        option.setLabel(request.getLabel());
        option.setDescription(request.getDescription());
        option.setIconUrl(request.getIconUrl());
        option.setDisplayOrder(displayOrder);
        option.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
        option.setMetadata(request.getMetadata());
        
        // Link to goal if goalId is provided
        if (request.getGoalId() != null) {
            Goal goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal not found: " + request.getGoalId()));
            option.setGoal(goal);
        }
        
        option = optionRepository.save(option);
        return onboardingMapper.toOptionResponse(option);
    }

    @Override
    @Transactional
    public OnboardingOptionResponse updateOption(Long optionId, SaveOnboardingOptionRequest request) {
        OnboardingOption option = optionRepository.findById(optionId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding option not found: " + optionId));
        
        // Check for duplicate option key if it's being changed
        if (!option.getOptionKey().equals(request.getOptionKey()) &&
            optionRepository.existsByStepStepIdAndOptionKey(option.getStep().getStepId(), request.getOptionKey())) {
            throw new IllegalArgumentException("Option key already exists for this step: " + request.getOptionKey());
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
        
        // Update goal link if goalId is provided
        if (request.getGoalId() != null) {
            Goal goal = goalRepository.findById(request.getGoalId())
                    .orElseThrow(() -> new ResourceNotFoundException("Goal not found: " + request.getGoalId()));
            option.setGoal(goal);
        } else {
            // If goalId is explicitly null, remove the link
            option.setGoal(null);
        }
        
        option = optionRepository.save(option);
        return onboardingMapper.toOptionResponse(option);
    }

    @Override
    @Transactional
    public void deleteOption(Long optionId) {
        OnboardingOption option = optionRepository.findById(optionId)
                .orElseThrow(() -> new ResourceNotFoundException("Onboarding option not found: " + optionId));
        optionRepository.delete(option);
    }

    // ============= Analytics =============

    @Override
    @Transactional(readOnly = true)
    public OnboardingAnalyticsResponse getOnboardingAnalytics(LocalDate from, LocalDate to) {
        LocalDateTime fromDateTime = from.atStartOfDay();
        LocalDateTime toDateTime = to.atTime(LocalTime.MAX);
        
        // Count completions
        long completedCount = progressRepository.countUsersCompletedBetween(fromDateTime, toDateTime);
        
        // Get completion and skip counts by step
        Map<Long, Long> completionsByStep = new HashMap<>();
        Map<Long, Long> skipsByStep = new HashMap<>();
        
        List<Object[]> completionStats = progressRepository.countByStepAndStatus(OnboardingStepStatus.COMPLETED);
        for (Object[] stat : completionStats) {
            completionsByStep.put((Long) stat[0], (Long) stat[1]);
        }
        
        List<Object[]> skipStats = progressRepository.countByStepAndStatus(OnboardingStepStatus.SKIPPED);
        for (Object[] stat : skipStats) {
            skipsByStep.put((Long) stat[0], (Long) stat[1]);
        }
        
        // Calculate total started (users with at least one progress entry)
        long totalStarted = completionsByStep.values().stream().max(Long::compareTo).orElse(0L);
        
        double completionRate = totalStarted > 0 ? (double) completedCount / totalStarted : 0.0;
        
        return OnboardingAnalyticsResponse.builder()
                .totalUsersStarted(totalStarted)
                .totalUsersCompleted(completedCount)
                .completionRate(completionRate)
                .completionsByStep(completionsByStep)
                .skipsByStep(skipsByStep)
                .popularOptionsByStep(new HashMap<>()) // TODO: Implement option analytics
                .build();
    }
}
