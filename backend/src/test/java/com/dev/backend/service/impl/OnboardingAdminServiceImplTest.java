package com.dev.backend.service.impl;

import com.dev.backend.mapper.OnboardingMapper;
import com.dev.backend.model.dto.request.SaveOnboardingOptionRequest;
import com.dev.backend.model.dto.request.SaveOnboardingStepRequest;
import com.dev.backend.model.dto.response.OnboardingOptionResponse;
import com.dev.backend.model.dto.response.OnboardingStepResponse;
import com.dev.backend.model.entity.OnboardingFlow;
import com.dev.backend.model.entity.OnboardingStep;
import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingFlowRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingRepository;
import com.dev.backend.repository.UserOnboardingStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mapstruct.factory.Mappers;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OnboardingAdminServiceImplTest {

    @Mock
    private OnboardingFlowRepository flowRepository;

    @Mock
    private OnboardingStepRepository stepRepository;

    @Mock
    private UserOnboardingRepository userOnboardingRepository;

    @Mock
    private UserOnboardingStepRepository userOnboardingStepRepository;

    @Mock
    private GoalRepository goalRepository;

    private OnboardingMapper onboardingMapper;
    private OnboardingAdminServiceImpl adminService;
    private OnboardingFlow defaultFlow;

    @BeforeEach
    void setUp() {
        onboardingMapper = Mappers.getMapper(OnboardingMapper.class);
        adminService = new OnboardingAdminServiceImpl(
                flowRepository,
                stepRepository,
                userOnboardingRepository,
                userOnboardingStepRepository,
                goalRepository,
                onboardingMapper
        );

        defaultFlow = new OnboardingFlow();
        defaultFlow.setId(1L);
        defaultFlow.setFlowKey("default_onboarding");
        defaultFlow.setName("Default User Onboarding");
        defaultFlow.setVersion(1);
        defaultFlow.setIsActive(true);
    }

    @Test
    @DisplayName("createStep serializes UI metadata into step.config JSON and assigns sequence")
    void createStep_SerializesConfigAndSaves() {
        SaveOnboardingStepRequest request = SaveOnboardingStepRequest.builder()
                .stepKey("gender")
                .title("Gender")
                .subtitle("What is your gender?")
                .helpText("Personalize your plan")
                .stepType(OnboardingStepType.GENDER)
                .isRequired(true)
                .isActive(true)
                .build();

        when(flowRepository.findFirstByIsActiveTrueOrderByVersionDesc()).thenReturn(Optional.of(defaultFlow));
        when(stepRepository.existsByFlowIdAndStepKey(1L, "gender")).thenReturn(false);
        when(stepRepository.findTopByFlowIdOrderBySequenceDesc(1L)).thenReturn(Optional.empty());
        when(stepRepository.save(any(OnboardingStep.class))).thenAnswer(inv -> {
            OnboardingStep s = inv.getArgument(0);
            s.setId(10L);
            return s;
        });

        OnboardingStepResponse response = adminService.createStep(request);

        assertThat(response.getStepId()).isEqualTo(10L);
        assertThat(response.getStepKey()).isEqualTo("gender");
        assertThat(response.getDisplayOrder()).isEqualTo(1);
        assertThat(response.getStepType()).isEqualTo(OnboardingStepType.GENDER);
        assertThat(response.getInputType()).isEqualTo(OnboardingInputType.SINGLE_CHOICE);
        assertThat(response.getSubtitle()).isEqualTo("What is your gender?");
    }

    @Test
    @DisplayName("createOption, updateOption, and deleteOption mutate options array in step.config JSON")
    void optionCrud_MutatesStepConfigJson() {
        OnboardingStep step = new OnboardingStep();
        step.setId(10L);
        step.setFlow(defaultFlow);
        step.setStepKey("gender");
        step.setTitle("Gender");
        step.setSequence(1);
        step.setIsRequired(true);

        when(stepRepository.findById(10L)).thenReturn(Optional.of(step));
        when(stepRepository.findAllByOrderBySequenceAsc()).thenReturn(List.of(step));
        when(stepRepository.save(any(OnboardingStep.class))).thenAnswer(inv -> inv.getArgument(0));

        SaveOnboardingOptionRequest createReq = SaveOnboardingOptionRequest.builder()
                .optionKey("female")
                .label("Female")
                .description("Female")
                .isActive(true)
                .build();

        OnboardingOptionResponse created = adminService.createOption(10L, createReq);
        assertThat(created.getOptionId()).isEqualTo(1L);
        assertThat(created.getOptionKey()).isEqualTo("female");
        assertThat(step.getParsedConfig().getOptions()).hasSize(1);

        SaveOnboardingOptionRequest updateReq = SaveOnboardingOptionRequest.builder()
                .optionKey("female")
                .label("Female Updated")
                .description("Updated description")
                .displayOrder(2)
                .isActive(true)
                .build();

        OnboardingOptionResponse updated = adminService.updateOption(1L, updateReq);
        assertThat(updated.getLabel()).isEqualTo("Female Updated");
        assertThat(updated.getDisplayOrder()).isEqualTo(2);

        adminService.deleteOption(1L);
        assertThat(step.getParsedConfig().getOptions()).isEmpty();
    }

    @Test
    @DisplayName("deleteStep checks countByStepIdAndStatus and prevents deleting step with user data")
    void deleteStep_WithExistingUserData_ThrowsException() {
        OnboardingStep step = new OnboardingStep();
        step.setId(10L);
        step.setStepKey("gender");

        when(stepRepository.findById(10L)).thenReturn(Optional.of(step));
        when(userOnboardingStepRepository.countByStepIdAndStatus(10L, OnboardingStepStatus.COMPLETED)).thenReturn(3L);

        assertThatThrownBy(() -> adminService.deleteStep(10L))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Cannot delete step with existing user data");

        verify(userOnboardingStepRepository).countByStepIdAndStatus(10L, OnboardingStepStatus.COMPLETED);
    }
}
