package com.dev.backend.mapper;

import com.dev.backend.model.dto.onboarding.OnboardingStepConfig;
import com.dev.backend.model.dto.onboarding.OnboardingStepConfig.OnboardingOptionItem;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingFlowResponse;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.entity.UserOnboardingStep;
import com.dev.backend.model.enums.OnboardingStepStatus;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Mapper for onboarding entities and config JSON to DTOs.
 */
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface OnboardingMapper extends BaseMapper<OnboardingStep, SaveOnboardingStepRequest, OnboardingStepResponse> {

    OnboardingOptionResponse toOptionResponse(OnboardingOptionItem option);

    List<OnboardingOptionResponse> toOptionResponseList(List<OnboardingOptionItem> options);

    @Override
    default OnboardingStepResponse toResponse(OnboardingStep step) {
        if (step == null) {
            return null;
        }
        OnboardingStepConfig cfg = step.getParsedConfig();
        List<OnboardingOptionResponse> optionResponses = null;
        if (cfg.getOptions() != null && !cfg.getOptions().isEmpty()) {
            optionResponses = cfg.getOptions().stream()
                    .sorted(Comparator.comparing(
                            o -> o.getDisplayOrder() != null ? o.getDisplayOrder() : Integer.MAX_VALUE))
                    .map(this::toOptionResponse)
                    .collect(Collectors.toList());
        }

        return OnboardingStepResponse.builder()
                .stepId(step.getId())
                .stepKey(step.getStepKey())
                .title(step.getTitle())
                .subtitle(cfg.getSubtitle())
                .helpText(cfg.getHelpText())
                .stepType(cfg.getStepType())
                .inputType(cfg.getInputType())
                .displayOrder(step.getSequence())
                .isRequired(step.getIsRequired())
                .isActive(cfg.getIsActive() != null ? cfg.getIsActive() : true)
                .iconUrl(cfg.getIconUrl())
                .options(optionResponses)
                .build();
    }

    default OnboardingStepResponse toStepResponseWithAllOptions(OnboardingStep step) {
        return toResponse(step);
    }

    default OnboardingStepResponse toStepResponse(OnboardingStep step, UserOnboardingStep progress) {
        if (step == null) {
            return null;
        }

        OnboardingStepResponse response = toResponse(step);
        OnboardingStepConfig cfg = step.getParsedConfig();

        if (cfg.getOptions() != null && !cfg.getOptions().isEmpty()) {
            List<OnboardingOptionResponse> options = cfg.getOptions().stream()
                    .filter(o -> o.getIsActive() == null || Boolean.TRUE.equals(o.getIsActive()))
                    .sorted(Comparator.comparing(
                            o -> o.getDisplayOrder() != null ? o.getDisplayOrder() : Integer.MAX_VALUE))
                    .map(this::toOptionResponse)
                    .collect(Collectors.toList());
            response.setOptions(options);
        } else {
            response.setOptions(null);
        }

        if (progress != null) {
            response.setStatus(progress.getStatus());
            response.setResponseData(progress.getAnswerData());
            response.setCompletedAt(progress.getCompletedAt());
        } else {
            response.setStatus(OnboardingStepStatus.PENDING);
        }

        return response;
    }

    default OnboardingFlowResponse toFlowResponse(
            List<OnboardingStep> steps,
            Map<Long, UserOnboardingStep> progressMap) {

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
                .map(step -> toStepResponse(step, progressMap.get(step.getId())))
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
