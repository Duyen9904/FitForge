package com.dev.backend.controller;

import com.dev.backend.model.dto.response.GoalResponse;
import com.dev.backend.service.GoalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(GoalController.class)
class GoalControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private GoalService goalService;

    private GoalResponse mockGoal;
    private List<GoalResponse> mockGoals;

    @BeforeEach
    void setUp() {
        mockGoal = GoalResponse.builder()
                .goalId(1L)
                .goalName("Fat Loss")
                .description("Reduce body fat percentage")
                .recommendedRepRange("12-15")
                .recommendedRestTime("60 seconds")
                .recommendedFrequency("4-5 days/week")
                .targetCalorieAdjustment(-500)
                .build();

        GoalResponse mockGoal2 = GoalResponse.builder()
                .goalId(2L)
                .goalName("Muscle Gain")
                .description("Build lean muscle mass")
                .recommendedRepRange("8-12")
                .recommendedRestTime("90 seconds")
                .recommendedFrequency("5-6 days/week")
                .targetCalorieAdjustment(300)
                .build();

        mockGoals = Arrays.asList(mockGoal, mockGoal2);
    }

    @Nested
    @DisplayName("GET /api/v1/goals")
    class GetAllGoalsTests {

        @Test
        @DisplayName("Should return all available fitness goals")
        void getAllGoals_Success() throws Exception {
            when(goalService.getAllGoals()).thenReturn(mockGoals);

            mockMvc.perform(get("/api/v1/goals")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(goalService, times(1)).getAllGoals();
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getAllGoals_NoAuth_ReturnsUnauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/goals"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/goals/{goalId}")
    class GetGoalByIdTests {

        @Test
        @DisplayName("Should return goal details by ID")
        void getGoalById_Success() throws Exception {
            when(goalService.getGoalById(anyLong())).thenReturn(mockGoal);

            mockMvc.perform(get("/api/v1/goals/1")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(goalService, times(1)).getGoalById(1L);
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getGoalById_NoAuth_ReturnsUnauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/goals/1"))
                    .andExpect(status().isUnauthorized());
        }
    }
}
