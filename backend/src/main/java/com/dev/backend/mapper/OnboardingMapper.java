package com.dev.backend.mapper;

import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.OnboardingOption;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.UserOnboardingProgress;
import com.dev.backend.model.enums.OnboardingStepStatus;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Mapper for onboarding entities to DTOs.
 */
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface OnboardingMapper extends BaseMapper<OnboardingStep, SaveOnboardingStepRequest, OnboardingStepResponse> {

    @Override
    @Mapping(target = "options", source = "options")
    OnboardingStepResponse toResponse(OnboardingStep step);

    @Override
    @Mapping(target = "isRequired", expression = "java(request.getIsRequired() != null ? request.getIsRequired() : true)")
    @Mapping(target = "isActive", expression = "java(request.getIsActive() != null ? request.getIsActive() : true)")
    OnboardingStep toEntity(SaveOnboardingStepRequest request);

    @Override
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromRequest(@MappingTarget OnboardingStep entity, SaveOnboardingStepRequest request);

    @Mapping(target = "goalId", source = "goal.goalId")
    OnboardingOptionResponse toOptionResponse(OnboardingOption option);

    List<OnboardingOptionResponse> toOptionResponseList(List<OnboardingOption> options);

    default OnboardingStepResponse toStepResponseWithAllOptions(OnboardingStep step) {
        return toResponse(step);
    }

    default OnboardingStepResponse toStepResponse(OnboardingStep step, UserOnboardingProgress progress) {
        if (step == null) {
            return null;
        }

        OnboardingStepResponse response = toResponse(step);

        if (step.getOptions() != null && !step.getOptions().isEmpty()) {
            List<OnboardingOptionResponse> options = step.getOptions().stream()
                    .filter(OnboardingOption::getIsActive)
                    .map(this::toOptionResponse)
                    .collect(Collectors.toList());
            response.setOptions(options);
        } else {
            response.setOptions(null);
        }

        if (progress != null) {
            response.setStatus(progress.getStatus());
            response.setResponseData(progress.getResponseData());
            response.setCompletedAt(progress.getCompletedAt());
        } else {
            response.setStatus(OnboardingStepStatus.PENDING);
        }

        return response;
    }

    default OnboardingFlowResponse toFlowResponse(
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
            } else if (!foundPending && Boolean.TRUE.equals(stepResponse.getIsRequired())) {
                currentIndex = i;
                foundPending = true;
            }
        }

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
