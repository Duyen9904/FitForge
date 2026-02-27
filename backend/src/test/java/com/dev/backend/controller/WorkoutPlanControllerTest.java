package com.dev.backend.controller;

import com.dev.backend.mapper.WorkoutPlanMapper;
import com.dev.backend.model.dto.request.RescheduleWorkoutSessionRequest;
import com.dev.backend.model.dto.request.UpdateSessionExerciseRequest;
import com.dev.backend.model.dto.response.WorkoutSessionResponse;
import com.dev.backend.model.dto.response.WorkoutTemplateSummaryResponse;
import com.dev.backend.service.WorkoutPlanService;
import com.dev.backend.service.WorkoutRecommendationService;
import com.dev.backend.exception.BadRequestException;
import com.dev.backend.exception.ResourceNotFoundException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(WorkoutPlanController.class)
class WorkoutPlanControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private WorkoutPlanService workoutPlanService;

    @MockBean
    private WorkoutRecommendationService workoutRecommendationService;

    @MockBean
    private WorkoutPlanMapper workoutPlanMapper;

    @Nested
    @DisplayName("PUT /api/v1/workout-plans/{planId}/sessions/{sessionId}/reschedule")
    class RescheduleSessionTests {

        @Test
        @DisplayName("Should reschedule upcoming session successfully")
        void rescheduleSession_Success() throws Exception {
            LocalDate newDate = LocalDate.now().plusDays(3);

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            WorkoutSessionResponse response = WorkoutSessionResponse.builder()
                    .sessionId(101L)
                    .scheduledDate(newDate)
                    .dayNumber(5)
                    .build();

            when(workoutPlanService.rescheduleSession(eq(1L), eq(42L), eq(101L), any(RescheduleWorkoutSessionRequest.class)))
                    .thenReturn(response);

            mockMvc.perform(put("/api/v1/workout-plans/42/sessions/101/reschedule")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.sessionId").value(101L))
                    .andExpect(jsonPath("$.data.scheduledDate").value(newDate.toString()));
        }

        @Test
        @DisplayName("Should return 400 when service rejects invalid date")
        void rescheduleSession_BadRequest_Returns400() throws Exception {
            LocalDate newDate = LocalDate.now().minusDays(1);

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            when(workoutPlanService.rescheduleSession(eq(1L), eq(42L), eq(101L), any(RescheduleWorkoutSessionRequest.class)))
                    .thenThrow(new BadRequestException("New date must be today or in the future"));

            mockMvc.perform(put("/api/v1/workout-plans/42/sessions/101/reschedule")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("Should return 404 when plan or session not found")
        void rescheduleSession_NotFound_Returns404() throws Exception {
            LocalDate newDate = LocalDate.now().plusDays(3);

            RescheduleWorkoutSessionRequest request = RescheduleWorkoutSessionRequest.builder()
                    .newDate(newDate)
                    .build();

            when(workoutPlanService.rescheduleSession(eq(1L), eq(42L), eq(999L), any(RescheduleWorkoutSessionRequest.class)))
                    .thenThrow(new ResourceNotFoundException("WorkoutSession", "id", 999L));

            mockMvc.perform(put("/api/v1/workout-plans/42/sessions/999/reschedule")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("Session Exercise Endpoints")
    class SessionExerciseEndpoints {

        @Test
        @DisplayName("Should update session exercise successfully")
        void updateSessionExercise_Success() throws Exception {
            UpdateSessionExerciseRequest request = UpdateSessionExerciseRequest.builder()
                    .sets(4)
                    .repetitions(8)
                    .build();

            WorkoutSessionResponse response = WorkoutSessionResponse.builder()
                    .sessionId(101L)
                    .build();

            when(workoutPlanService.updateSessionExercise(eq(1L), eq(42L), eq(101L), eq(10L), any(UpdateSessionExerciseRequest.class)))
                    .thenReturn(response);

            mockMvc.perform(put("/api/v1/workout-plans/42/sessions/101/exercises/10")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.sessionId").value(101L));
        }

        @Test
        @DisplayName("Should delete session exercise successfully")
        void deleteSessionExercise_Success() throws Exception {
            mockMvc.perform(delete("/api/v1/workout-plans/42/sessions/101/exercises/10")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf()))
                    .andExpect(status().isNoContent());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/workout-plans/templates/recommended")
    class GetRecommendedTemplatesTests {

        @Test
        @DisplayName("Should return recommended templates for authenticated user")
        void getRecommendedTemplates_Success() throws Exception {
            WorkoutTemplateSummaryResponse template = WorkoutTemplateSummaryResponse.builder()
                    .id(100L)
                    .name("Full Body Beginner")
                    .goalType("MUSCLE_GAIN")
                    .experienceLevel("BEGINNER")
                    .daysPerWeek(3)
                    .equipmentTags("DUMBBELLS")
                    .recommendationReason("Matches your profile")
                    .build();

            when(workoutRecommendationService.getRecommendedTemplates(1L, 5))
                    .thenReturn(List.of(template));

            mockMvc.perform(get("/api/v1/workout-plans/templates/recommended")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data[0].id").value(100L))
                    .andExpect(jsonPath("$.data[0].name").value("Full Body Beginner"))
                    .andExpect(jsonPath("$.data[0].goalType").value("MUSCLE_GAIN"))
                    .andExpect(jsonPath("$.data[0].experienceLevel").value("BEGINNER"))
                    .andExpect(jsonPath("$.data[0].daysPerWeek").value(3));
        }
    }
}

