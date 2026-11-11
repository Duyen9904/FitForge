package com.dev.backend.service.impl;

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
import com.dev.backend.model.enums.OnboardingInputType;
import com.dev.backend.model.enums.OnboardingStatus;
import com.dev.backend.model.enums.OnboardingStepStatus;
import com.dev.backend.model.enums.OnboardingStepType;
import com.dev.backend.repository.GoalRepository;
import com.dev.backend.repository.OnboardingFlowRepository;
import com.dev.backend.repository.OnboardingStepRepository;
import com.dev.backend.repository.UserOnboardingRepository;
import com.dev.backend.repository.UserOnboardingStepRepository;
import com.dev.backend.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
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
class OnboardingServiceImplTest {

    @Mock
    private OnboardingFlowRepository flowRepository;

    @Mock
    private OnboardingStepRepository stepRepository;

    @Mock
    private UserOnboardingRepository userOnboardingRepository;

    @Mock
    private UserOnboardingStepRepository userOnboardingStepRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private GoalRepository goalRepository;

    private OnboardingMapper onboardingMapper;
    private ObjectMapper objectMapper;
    private OnboardingServiceImpl onboardingService;

    private OnboardingFlow flow;
    private OnboardingStep genderStep;
    private OnboardingStep goalStep;
    private OnboardingStep optionalStep;
    private User user;
    private UserOnboarding userOnboarding;

    @BeforeEach
    void setUp() {
        onboardingMapper = Mappers.getMapper(OnboardingMapper.class);
        objectMapper = new ObjectMapper();
        onboardingService = new OnboardingServiceImpl(
                flowRepository,
                stepRepository,
                userOnboardingRepository,
                userOnboardingStepRepository,
                userRepository,
                goalRepository,
                onboardingMapper,
                objectMapper
        );

        flow = new OnboardingFlow();
        flow.setId(1L);
        flow.setFlowKey("default_onboarding");
        flow.setName("Default User Onboarding");
        flow.setVersion(1);
        flow.setIsActive(true);

        genderStep = new OnboardingStep();
        genderStep.setId(10L);
        genderStep.setFlow(flow);
        genderStep.setStepKey("gender");
        genderStep.setTitle("Gender");
        genderStep.setSequence(1);
        genderStep.setIsRequired(true);
        genderStep.setParsedConfig(OnboardingStepConfig.builder()
                .subtitle("What is your gender?")
                .stepType(OnboardingStepType.GENDER)
                .inputType(OnboardingInputType.SINGLE_CHOICE)
                .isActive(true)
                .options(List.of(
                        OnboardingOptionItem.builder().optionId(1L).optionKey("female").label("Female").displayOrder(1).isActive(true).build(),
                        OnboardingOptionItem.builder().optionId(2L).optionKey("male").label("Male").displayOrder(2).isActive(true).build()
                ))
                .build());

        goalStep = new OnboardingStep();
        goalStep.setId(20L);
        goalStep.setFlow(flow);
        goalStep.setStepKey("fitness_goal");
        goalStep.setTitle("Fitness Goal");
        goalStep.setSequence(2);
        goalStep.setIsRequired(true);
        goalStep.setParsedConfig(OnboardingStepConfig.builder()
                .subtitle("Select your primary goal")
                .stepType(OnboardingStepType.FITNESS_GOAL)
                .inputType(OnboardingInputType.MULTIPLE_CHOICE)
                .isActive(true)
                .options(List.of(
                        OnboardingOptionItem.builder().optionId(6L).optionKey("slimfit").label("Slimfit").displayOrder(1).isActive(true).goalId(100L).build()
                ))
                .build());

        optionalStep = new OnboardingStep();
        optionalStep.setId(30L);
        optionalStep.setFlow(flow);
        optionalStep.setStepKey("notifications");
        optionalStep.setTitle("Notifications");
        optionalStep.setSequence(3);
        optionalStep.setIsRequired(false);
        optionalStep.setParsedConfig(OnboardingStepConfig.builder()
                .subtitle("Stay on track")
                .stepType(OnboardingStepType.NOTIFICATIONS)
                .inputType(OnboardingInputType.TOGGLE)
                .isActive(true)
                .options(List.of())
                .build());

        user = new User();
        user.setUserId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setOnboardingCompleted(false);

        userOnboarding = new UserOnboarding();
        userOnboarding.setId(500L);
        userOnboarding.setUser(user);
        userOnboarding.setFlow(flow);
        userOnboarding.setStatus(OnboardingStatus.IN_PROGRESS);
        userOnboarding.setCurrentStep(genderStep);
    }

    @Test
    @DisplayName("getOnboardingFlow initializes UserOnboarding and returns mapped steps with options from config")
    void getOnboardingFlow_InitializesSessionAndMapsSteps() {
        when(userOnboardingRepository.findFirstByUserUserIdOrderByStartedAtDesc(1L)).thenReturn(Optional.empty());
        when(flowRepository.findFirstByIsActiveTrueOrderByVersionDesc()).thenReturn(Optional.of(flow));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(stepRepository.findByFlowIdOrderBySequenceAsc(1L)).thenReturn(List.of(genderStep, goalStep, optionalStep));
        when(userOnboardingRepository.save(any(UserOnboarding.class))).thenReturn(userOnboarding);
        when(userOnboardingStepRepository.findByOnboardingId(500L)).thenReturn(List.of());

        OnboardingFlowResponse response = onboardingService.getOnboardingFlow(1L);

        assertThat(response.getTotalSteps()).isEqualTo(3);
        assertThat(response.getCompletedSteps()).isEqualTo(0);
        assertThat(response.getCurrentStepIndex()).isEqualTo(0);
        assertThat(response.getIsComplete()).isFalse();
        assertThat(response.getSteps()).hasSize(3);
        assertThat(response.getSteps().get(0).getStepId()).isEqualTo(10L);
        assertThat(response.getSteps().get(0).getInputType()).isEqualTo(OnboardingInputType.SINGLE_CHOICE);
        assertThat(response.getSteps().get(0).getOptions()).hasSize(2);
    }

    @Test
    @DisplayName("submitStepResponse saves answer_data, updates User.primaryGoal via config option goalId, and advances currentStep")
    void submitStepResponse_FitnessGoalOptionId_UpdatesGoalAndCurrentStep() {
        Goal slimfitGoal = new Goal();
        slimfitGoal.setGoalId(100L);
        slimfitGoal.setGoalName("Slimfit");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(stepRepository.findById(20L)).thenReturn(Optional.of(goalStep));
        when(userOnboardingRepository.findByUserUserIdAndFlowId(1L, 1L)).thenReturn(Optional.of(userOnboarding));
        when(userOnboardingStepRepository.findByOnboardingIdAndStepId(500L, 20L)).thenReturn(Optional.empty());
        when(goalRepository.findById(100L)).thenReturn(Optional.of(slimfitGoal));
        when(stepRepository.findByFlowIdOrderBySequenceAsc(1L)).thenReturn(List.of(genderStep, goalStep, optionalStep));

        UserOnboardingStep genderDone = new UserOnboardingStep();
        genderDone.setId(new UserOnboardingStepId(500L, 10L));
        genderDone.setOnboarding(userOnboarding);
        genderDone.setStep(genderStep);
        genderDone.setStatus(OnboardingStepStatus.COMPLETED);

        UserOnboardingStep goalDone = new UserOnboardingStep();
        goalDone.setId(new UserOnboardingStepId(500L, 20L));
        goalDone.setOnboarding(userOnboarding);
        goalDone.setStep(goalStep);
        goalDone.setStatus(OnboardingStepStatus.COMPLETED);
        goalDone.setAnswerData("{\"optionId\": 6}");

        when(userOnboardingStepRepository.findByOnboardingId(500L)).thenReturn(List.of(genderDone, goalDone));

        SubmitOnboardingStepRequest request = new SubmitOnboardingStepRequest("{\"optionId\": 6}");
        OnboardingProgressResponse progress = onboardingService.submitStepResponse(1L, 20L, request);

        assertThat(user.getPrimaryGoal()).isNotNull();
        assertThat(user.getPrimaryGoal().getGoalId()).isEqualTo(100L);
        assertThat(progress.getStatus()).isEqualTo(OnboardingStepStatus.COMPLETED);
        assertThat(progress.getNextStepId()).isEqualTo(30L);
        assertThat(progress.getOnboardingComplete()).isTrue();
        assertThat(userOnboarding.getCurrentStep()).isEqualTo(optionalStep);
    }

    @Test
    @DisplayName("completeOnboarding marks UserOnboarding COMPLETED and sets User.onboardingCompleted = true")
    void completeOnboarding_AllRequiredStepsComplete_MarksCompleted() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(flowRepository.findFirstByIsActiveTrueOrderByVersionDesc()).thenReturn(Optional.of(flow));
        when(userOnboardingRepository.findFirstByUserUserIdOrderByStartedAtDesc(1L)).thenReturn(Optional.of(userOnboarding));
        when(stepRepository.findByFlowIdOrderBySequenceAsc(1L)).thenReturn(List.of(genderStep, goalStep, optionalStep));
        when(userOnboardingStepRepository.existsByOnboardingIdAndStepIdAndStatus(500L, 10L, OnboardingStepStatus.COMPLETED)).thenReturn(true);
        when(userOnboardingStepRepository.existsByOnboardingIdAndStepIdAndStatus(500L, 20L, OnboardingStepStatus.COMPLETED)).thenReturn(true);

        onboardingService.completeOnboarding(1L);

        assertThat(user.getOnboardingCompleted()).isTrue();
        assertThat(userOnboarding.getStatus()).isEqualTo(OnboardingStatus.COMPLETED);
        assertThat(userOnboarding.getCompletedAt()).isNotNull();
        assertThat(userOnboarding.getCurrentStep()).isNull();
        verify(userOnboardingRepository).save(userOnboarding);
        verify(userRepository).save(user);
    }

    @Test
    @DisplayName("skipStep throws IllegalStateException when step is required")
    void skipStep_RequiredStep_ThrowsException() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(stepRepository.findById(10L)).thenReturn(Optional.of(genderStep));

        assertThatThrownBy(() -> onboardingService.skipStep(1L, 10L))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Cannot skip required step");
    }
}
