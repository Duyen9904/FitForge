package com.dev.backend.controller;

import com.dev.backend.model.dto.request.DataExportRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.service.ReportService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ReportController.class)
class ReportControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ReportService reportService;

    private WorkoutSummaryReportResponse mockWorkoutReport;
    private NutritionReportResponse mockNutritionReport;
    private TransformationReportResponse mockTransformationReport;

    @BeforeEach
    void setUp() {
        mockWorkoutReport = WorkoutSummaryReportResponse.builder()
                .startDate(LocalDate.of(2026, 1, 1))
                .endDate(LocalDate.of(2026, 1, 31))
                .totalWorkoutsCompleted(20)
                .totalWorkoutsPlanned(24)
                .adherencePercentage(83.3)
                .totalDurationMinutes(1200)
                .totalCaloriesBurned(8000)
                .missedWorkouts(4)
                .recommendations(Arrays.asList("Great consistency!", "Try adding more variety"))
                .build();

        mockNutritionReport = NutritionReportResponse.builder()
                .startDate(LocalDate.of(2026, 1, 1))
                .endDate(LocalDate.of(2026, 1, 31))
                .averageDailyCalories(2200.0)
                .averageDailyProtein(150.0)
                .averageDailyCarbs(250.0)
                .averageDailyFats(70.0)
                .proteinPercentage(27.3)
                .carbsPercentage(45.5)
                .fatsPercentage(27.2)
                .totalCheatMealDays(3)
                .cheatMealFrequencyPerWeek(0.7)
                .recommendations(Arrays.asList("Good protein intake"))
                .build();

        mockTransformationReport = TransformationReportResponse.builder()
                .startDate(LocalDate.of(2026, 1, 1))
                .endDate(LocalDate.of(2026, 1, 31))
                .startingWeight(80.0f)
                .currentWeight(78.5f)
                .weightChange(-1.5f)
                .targetWeight(75.0f)
                .progressToTargetPercentage(30.0)
                .milestones(Arrays.asList("Lost 1.5 kg - Great progress!"))
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/reports/workout-summary")
    class GetWorkoutSummaryReportTests {

        @Test
        @DisplayName("Should return workout summary report")
        void getWorkoutSummaryReport_Success() throws Exception {
            when(reportService.generateWorkoutSummaryReport(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(mockWorkoutReport);

            mockMvc.perform(get("/api/v1/reports/workout-summary")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .param("startDate", "2026-01-01")
                            .param("endDate", "2026-01-31"))
                    .andExpect(status().isOk());

            verify(reportService, times(1)).generateWorkoutSummaryReport(
                    eq(1L), 
                    eq(LocalDate.of(2026, 1, 1)), 
                    eq(LocalDate.of(2026, 1, 31)));
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getWorkoutSummaryReport_NoAuth_ReturnsUnauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/reports/workout-summary")
                            .param("startDate", "2026-01-01")
                            .param("endDate", "2026-01-31"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("Should return 400 when missing required params")
        void getWorkoutSummaryReport_MissingParams_ReturnsBadRequest() throws Exception {
            mockMvc.perform(get("/api/v1/reports/workout-summary")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/reports/nutrition")
    class GetNutritionReportTests {

        @Test
        @DisplayName("Should return nutrition report")
        void getNutritionReport_Success() throws Exception {
            when(reportService.generateNutritionReport(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(mockNutritionReport);

            mockMvc.perform(get("/api/v1/reports/nutrition")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .param("startDate", "2026-01-01")
                            .param("endDate", "2026-01-31"))
                    .andExpect(status().isOk());

            verify(reportService, times(1)).generateNutritionReport(
                    eq(1L),
                    eq(LocalDate.of(2026, 1, 1)),
                    eq(LocalDate.of(2026, 1, 31)));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/reports/transformation")
    class GetTransformationReportTests {

        @Test
        @DisplayName("Should return transformation report")
        void getTransformationReport_Success() throws Exception {
            when(reportService.generateTransformationReport(anyLong(), any(LocalDate.class), any(LocalDate.class)))
                    .thenReturn(mockTransformationReport);

            mockMvc.perform(get("/api/v1/reports/transformation")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .param("startDate", "2026-01-01")
                            .param("endDate", "2026-01-31"))
                    .andExpect(status().isOk());

            verify(reportService, times(1)).generateTransformationReport(
                    eq(1L),
                    eq(LocalDate.of(2026, 1, 1)),
                    eq(LocalDate.of(2026, 1, 31)));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/reports/export")
    class ExportDataTests {

        @Test
        @DisplayName("Should export data as JSON")
        void exportData_JSON_Success() throws Exception {
            DataExportRequest request = DataExportRequest.builder()
                    .dataTypes(Arrays.asList(
                            DataExportRequest.ExportDataType.WORKOUT_HISTORY,
                            DataExportRequest.ExportDataType.NUTRITION_LOGS))
                    .format(DataExportRequest.ExportFormat.JSON)
                    .startDate(LocalDate.of(2026, 1, 1))
                    .endDate(LocalDate.of(2026, 1, 31))
                    .build();

            byte[] mockData = "{\"userId\":1,\"data\":{}}".getBytes();
            when(reportService.exportData(anyLong(), any(DataExportRequest.class)))
                    .thenReturn(mockData);

            mockMvc.perform(post("/api/v1/reports/export")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Content-Disposition", "attachment; filename=\"fitness_export.json\""));

            verify(reportService, times(1)).exportData(eq(1L), any(DataExportRequest.class));
        }

        @Test
        @DisplayName("Should export data as CSV")
        void exportData_CSV_Success() throws Exception {
            DataExportRequest request = DataExportRequest.builder()
                    .dataTypes(Arrays.asList(DataExportRequest.ExportDataType.MEASUREMENTS))
                    .format(DataExportRequest.ExportFormat.CSV)
                    .startDate(LocalDate.of(2026, 1, 1))
                    .endDate(LocalDate.of(2026, 1, 31))
                    .build();

            byte[] mockData = "date,weight\n2026-01-01,80.0".getBytes();
            when(reportService.exportData(anyLong(), any(DataExportRequest.class)))
                    .thenReturn(mockData);

            mockMvc.perform(post("/api/v1/reports/export")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Content-Disposition", "attachment; filename=\"fitness_export.csv\""));
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void exportData_NoAuth_ReturnsUnauthorized() throws Exception {
            DataExportRequest request = DataExportRequest.builder()
                    .dataTypes(Arrays.asList(DataExportRequest.ExportDataType.WORKOUT_HISTORY))
                    .format(DataExportRequest.ExportFormat.JSON)
                    .build();

            mockMvc.perform(post("/api/v1/reports/export")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isUnauthorized());
        }
    }
}
