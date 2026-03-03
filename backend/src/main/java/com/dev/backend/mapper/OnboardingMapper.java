package com.dev.backend.mapper;

import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.OnboardingOption;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepStatus;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Mapper for onboarding entities to DTOs.
 */
@Component
public class OnboardingMapper {

    public OnboardingOptionResponse toOptionResponse(OnboardingOption option) {
        if (option == null) {
            return null;
        }
        return OnboardingOptionResponse.builder()
                .optionId(option.getOptionId())
                .optionKey(option.getOptionKey())
                .label(option.getLabel())
                .description(option.getDescription())
                .iconUrl(option.getIconUrl())
                .displayOrder(option.getDisplayOrder())
                .isActive(option.getIsActive())
                .metadata(option.getMetadata())
                .goalId(option.getGoal() != null ? option.getGoal().getGoalId() : null)
                .build();
    }

    public OnboardingStepResponse toStepResponse(OnboardingStep step, UserOnboardingProgress progress) {
        if (step == null) {
            return null;
        }
        
        OnboardingStepResponse.OnboardingStepResponseBuilder builder = OnboardingStepResponse.builder()
                .stepId(step.getStepId())
                .stepKey(step.getStepKey())
                .title(step.getTitle())
                .subtitle(step.getSubtitle())
                .helpText(step.getHelpText())
                .stepType(step.getStepType())
                .inputType(step.getInputType())
                .displayOrder(step.getDisplayOrder())
                .isRequired(step.getIsRequired())
                .isActive(step.getIsActive())
                .iconUrl(step.getIconUrl());
        
        // Include options for selection-based steps
        if (step.getOptions() != null && !step.getOptions().isEmpty()) {
            List<OnboardingOptionResponse> options = step.getOptions().stream()
                    .filter(OnboardingOption::getIsActive)
                    .map(this::toOptionResponse)
                    .collect(Collectors.toList());
            builder.options(options);
        }
        
        // Include user progress if available
        if (progress != null) {
            builder.status(progress.getStatus())
                    .responseData(progress.getResponseData())
                    .completedAt(progress.getCompletedAt());
        } else {
            builder.status(OnboardingStepStatus.PENDING);
        }
        
        return builder.build();
    }

    public OnboardingStepResponse toStepResponseWithAllOptions(OnboardingStep step) {
        if (step == null) {
            return null;
        }
        
        OnboardingStepResponse.OnboardingStepResponseBuilder builder = OnboardingStepResponse.builder()
                .stepId(step.getStepId())
                .stepKey(step.getStepKey())
                .title(step.getTitle())
                .subtitle(step.getSubtitle())
                .helpText(step.getHelpText())
                .stepType(step.getStepType())
                .inputType(step.getInputType())
                .displayOrder(step.getDisplayOrder())
                .isRequired(step.getIsRequired())
                .isActive(step.getIsActive())
                .iconUrl(step.getIconUrl());
        
        // Include all options (for admin view)
        if (step.getOptions() != null) {
            List<OnboardingOptionResponse> options = step.getOptions().stream()
                    .map(this::toOptionResponse)
                    .collect(Collectors.toList());
            builder.options(options);
        }
        
        return builder.build();
    }

    public OnboardingFlowResponse toFlowResponse(
            List<OnboardingStep> steps,
            Map<Long, UserOnboardingProgress> progressMap) {
        
        if (steps == null || steps.isEmpty()) {
            return OnboardingFlowResponse.builder()
                    .totalSteps(0)
                    .completedSteps(0)
                    .currentStepIndex(0)
                    .isComplete(true)
                    .steps(List.of())
                    .build();
        }
        
        List<OnboardingStepResponse> stepResponses = steps.stream()
                .map(step -> toStepResponse(step, progressMap.get(step.getStepId())))
                .collect(Collectors.toList());
        
        int completedCount = 0;
        int currentIndex = 0;
        boolean foundPending = false;
        
        for (int i = 0; i < stepResponses.size(); i++) {
            OnboardingStepResponse stepResponse = stepResponses.get(i);
            OnboardingStepStatus status = stepResponse.getStatus();
            
            if (status == OnboardingStepStatus.COMPLETED || status == OnboardingStepStatus.SKIPPED) {
                completedCount++;
            } else if (!foundPending && stepResponse.getIsRequired()) {
                currentIndex = i;
                foundPending = true;
            }
        }
        
        // If no pending required steps found, check if all required are done
        boolean isComplete = !foundPending;
        if (!foundPending && !stepResponses.isEmpty()) {
            currentIndex = stepResponses.size() - 1;
        }
        
        return OnboardingFlowResponse.builder()
                .totalSteps(steps.size())
                .completedSteps(completedCount)
                .currentStepIndex(currentIndex)
                .isComplete(isComplete)
                .steps(stepResponses)
                .build();
    }
}
