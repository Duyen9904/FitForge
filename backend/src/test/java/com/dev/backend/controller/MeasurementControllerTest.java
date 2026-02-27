package com.dev.backend.controller;

import com.dev.backend.model.dto.request.RecordMeasurementRequest;
import com.dev.backend.model.dto.request.SetMeasurementGoalRequest;
import com.dev.backend.model.dto.response.MeasurementGoalResponse;
import com.dev.backend.model.dto.response.MeasurementHistoryResponse;
import com.dev.backend.model.dto.response.MeasurementResponse;
import com.dev.backend.model.dto.response.ProgressPhotoResponse;
import com.dev.backend.service.MeasurementService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MeasurementController.class)
class MeasurementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private MeasurementService measurementService;

    private MeasurementResponse mockMeasurementResponse;
    private MeasurementHistoryResponse mockHistoryResponse;
    private MeasurementGoalResponse mockGoalResponse;

    @BeforeEach
    void setUp() {
        mockMeasurementResponse = MeasurementResponse.builder()
                .measurementId(1L)
                .measurementDate(LocalDate.now())
                .weightKg(75.0f)
                .bodyFatPercentage(18.0f)
                .waistCm(85.0f)
                .build();

        mockHistoryResponse = MeasurementHistoryResponse.builder()
                .measurements(List.of(mockMeasurementResponse))
                .trends(null)
                .build();

        mockGoalResponse = MeasurementGoalResponse.builder()
                .goalId(1L)
                .targetWeightKg(70.0f)
                .targetBodyFatPercentage(15.0f)
                .targetDate(LocalDate.now().plusMonths(3))
                .daysRemaining(90L)
                .build();
    }

    @Nested
    @DisplayName("POST /api/v1/measurements")
    class RecordMeasurementTests {

        @Test
        @DisplayName("Should record measurement successfully")
        void recordMeasurement_Success() throws Exception {
            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(75.0f)
                    .bodyFatPercentage(18.0f)
                    .build();

            when(measurementService.recordMeasurement(eq(1L), any(RecordMeasurementRequest.class)))
                    .thenReturn(mockMeasurementResponse);

            mockMvc.perform(post("/api/v1/measurements")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.measurementId").value(1))
                    .andExpect(jsonPath("$.data.weightKg").value(75.0));
        }

        @Test
        @DisplayName("Should return 400 when weight is negative")
        void recordMeasurement_InvalidWeight_ReturnsBadRequest() throws Exception {
            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(-5.0f)
                    .build();

            mockMvc.perform(post("/api/v1/measurements")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("Should return 401 without authentication")
        void recordMeasurement_Unauthorized() throws Exception {
            RecordMeasurementRequest request = RecordMeasurementRequest.builder()
                    .measurementDate(LocalDate.now())
                    .weightKg(75.0f)
                    .build();

            mockMvc.perform(post("/api/v1/measurements")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/measurements")
    class GetMeasurementHistoryTests {

        @Test
        @DisplayName("Should return measurement history")
        void getMeasurementHistory_Success() throws Exception {
            when(measurementService.getMeasurementHistory(eq(1L), any(), any()))
                    .thenReturn(mockHistoryResponse);

            mockMvc.perform(get("/api/v1/measurements")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .param("startDate", LocalDate.now().minusDays(30).toString())
                            .param("endDate", LocalDate.now().toString()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.measurements").isArray());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/measurements/latest")
    class GetLatestMeasurementTests {

        @Test
        @DisplayName("Should return latest measurement")
        void getLatestMeasurement_Success() throws Exception {
            when(measurementService.getLatestMeasurement(1L))
                    .thenReturn(mockMeasurementResponse);

            mockMvc.perform(get("/api/v1/measurements/latest")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.weightKg").value(75.0));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/measurements/goals")
    class SetMeasurementGoalTests {

        @Test
        @DisplayName("Should set measurement goal successfully")
        void setMeasurementGoal_Success() throws Exception {
            SetMeasurementGoalRequest request = SetMeasurementGoalRequest.builder()
                    .targetWeightKg(70.0f)
                    .targetBodyFatPercentage(15.0f)
                    .targetDate(LocalDate.now().plusMonths(3))
                    .build();

            when(measurementService.setMeasurementGoal(eq(1L), any(SetMeasurementGoalRequest.class)))
                    .thenReturn(mockGoalResponse);

            mockMvc.perform(post("/api/v1/measurements/goals")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.targetWeightKg").value(70.0));
        }

        @Test
        @DisplayName("Should return 400 when target date is in the past")
        void setMeasurementGoal_PastDate_ReturnsBadRequest() throws Exception {
            SetMeasurementGoalRequest request = SetMeasurementGoalRequest.builder()
                    .targetWeightKg(70.0f)
                    .targetDate(LocalDate.now().minusDays(1))
                    .build();

            mockMvc.perform(post("/api/v1/measurements/goals")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/measurements/goals")
    class GetMeasurementGoalTests {

        @Test
        @DisplayName("Should return measurement goal")
        void getMeasurementGoal_Success() throws Exception {
            when(measurementService.getMeasurementGoal(1L))
                    .thenReturn(mockGoalResponse);

            mockMvc.perform(get("/api/v1/measurements/goals")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.targetWeightKg").value(70.0))
                    .andExpect(jsonPath("$.data.daysRemaining").value(90));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/measurements/photos")
    class GetProgressPhotosTests {

        @Test
        @DisplayName("Should return progress photos")
        void getProgressPhotos_Success() throws Exception {
            List<ProgressPhotoResponse> photos = List.of(
                    ProgressPhotoResponse.builder()
                            .photoId(1L)
                            .photoUrl("/uploads/photo1.jpg")
                            .category("front")
                            .build()
            );

            when(measurementService.getProgressPhotos(1L)).thenReturn(photos);

            mockMvc.perform(get("/api/v1/measurements/photos")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data[0].photoId").value(1));
        }

        @Test
        @DisplayName("Should filter photos by category")
        void getProgressPhotos_FilterByCategory() throws Exception {
            List<ProgressPhotoResponse> photos = List.of(
                    ProgressPhotoResponse.builder()
                            .photoId(1L)
                            .category("front")
                            .build()
            );

            when(measurementService.getProgressPhotosByCategory(1L, "front")).thenReturn(photos);

            mockMvc.perform(get("/api/v1/measurements/photos")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .param("category", "front"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data[0].category").value("front"));
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/measurements/photos/{photoId}")
    class DeleteProgressPhotoTests {

        @Test
        @DisplayName("Should delete progress photo")
        void deleteProgressPhoto_Success() throws Exception {
            doNothing().when(measurementService).deleteProgressPhoto(1L, 1L);

            mockMvc.perform(delete("/api/v1/measurements/photos/1")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf()))
                    .andExpect(status().isNoContent());

            verify(measurementService, times(1)).deleteProgressPhoto(1L, 1L);
        }
    }
}
