package com.dev.backend.controller;

import com.dev.backend.model.dto.response.AdminAnalyticsResponse;
import com.dev.backend.service.AdminAnalyticsService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AdminController.class)
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AdminAnalyticsService adminAnalyticsService;

    private AdminAnalyticsResponse mockAnalytics;

    @BeforeEach
    void setUp() {
        mockAnalytics = AdminAnalyticsResponse.builder()
                .totalUsers(1000L)
                .activeUsersLast30Days(750L)
                .newUsersThisMonth(100L)
                .averageWorkoutsPerUser(50.0)
                .totalWorkoutsCompleted(50000L)
                .averageAdherenceRatePercent(85.0)
                .mostPopularExercises(List.of())
                .mostPopularGoals(List.of())
                .totalCheatMealsLogged(2000L)
                .averageCheatMealsPerWeek(1.5)
                .missedWorkoutReasons(Map.of("SICK", 100L, "BUSY", 200L))
                .totalMissedWorkouts(5000L)
                .totalMeasurementsRecorded(10000L)
                .totalProgressPhotos(3000L)
                .usersWithActiveStreaks(300L)
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/admin/analytics")
    class GetSystemAnalyticsTests {

        @Test
        @DisplayName("Should return analytics for admin user")
        @WithMockUser(roles = "ADMIN")
        void getAnalytics_AdminSuccess() throws Exception {
            when(adminAnalyticsService.getSystemAnalytics()).thenReturn(mockAnalytics);

            mockMvc.perform(get("/api/v1/admin/analytics")
                            .with(jwt().jwt(j -> j.subject("1")
                                    .claim("scope", "ROLE_ADMIN"))))
                    .andExpect(status().isOk());
        }

        @Test
        @DisplayName("Should return 403 for non-admin user")
        void getAnalytics_NonAdmin_Forbidden() throws Exception {
            mockMvc.perform(get("/api/v1/admin/analytics")
                            .with(jwt().jwt(j -> j.subject("1")
                                    .claim("scope", "ROLE_USER"))))
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getAnalytics_Unauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/admin/analytics"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/admin/analytics/export")
    class ExportAnalyticsReportTests {

        @Test
        @DisplayName("Should export CSV for admin user")
        @WithMockUser(roles = "ADMIN")
        void exportReport_AdminSuccess() throws Exception {
            byte[] csvData = "Metric,Value\nTotal Users,1000\n".getBytes();
            when(adminAnalyticsService.exportAnalyticsReport()).thenReturn(csvData);

            mockMvc.perform(get("/api/v1/admin/analytics/export")
                            .with(jwt().jwt(j -> j.subject("1")
                                    .claim("scope", "ROLE_ADMIN"))))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Content-Type", "text/csv"))
                    .andExpect(header().exists("Content-Disposition"));
        }

        @Test
        @DisplayName("Should return 403 for non-admin user")
        void exportReport_NonAdmin_Forbidden() throws Exception {
            mockMvc.perform(get("/api/v1/admin/analytics/export")
                            .with(jwt().jwt(j -> j.subject("1")
                                    .claim("scope", "ROLE_USER"))))
                    .andExpect(status().isForbidden());
        }
    }
}
