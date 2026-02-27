package com.dev.backend.controller;

import com.dev.backend.model.dto.request.RescheduleMissedWorkoutRequest;
import com.dev.backend.model.dto.request.SelectMakeupOptionRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.model.enums.MakeupOption;
import com.dev.backend.model.enums.MissedWorkoutReason;
import com.dev.backend.service.MissedWorkoutService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MissedWorkoutController.class)
class MissedWorkoutControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private MissedWorkoutService missedWorkoutService;

    private MissedWorkoutResponse mockMissedWorkoutResponse;
    private MakeupWorkoutOptionResponse mockMakeupOption;
    private MissedWorkoutReportResponse mockReport;

    @BeforeEach
    void setUp() {
        mockMissedWorkoutResponse = MissedWorkoutResponse.builder()
                .missedWorkoutId(1L)
                .sessionId(1L)
                .sessionName("Push Day")
                .planName("Strength Training")
                .scheduledDate(LocalDate.now().minusDays(1))
                .missedDate(LocalDate.now())
                .reason(MissedWorkoutReason.TOO_BUSY)
                .isReplanned(false)
                .compensationActions(new ArrayList<>())
                .build();

        mockMakeupOption = MakeupWorkoutOptionResponse.builder()
                .option(MakeupOption.RESCHEDULE_NEXT_DAY)
                .description("Reschedule to tomorrow")
                .detailedExplanation("Move Push Day to tomorrow")
                .affectedDates(List.of(LocalDate.now().plusDays(1)))
                .estimatedRecoveryDays(1)
                .recommendation("Recommended")
                .build();

        Map<String, Integer> byDayOfWeek = new HashMap<>();
        byDayOfWeek.put("Monday", 3);
        Map<String, Integer> byReason = new HashMap<>();
        byReason.put("TOO_BUSY", 2);

        mockReport = MissedWorkoutReportResponse.builder()
                .totalMissedWorkouts(5)
                .totalCompletedWorkouts(15)
                .adherencePercentage(75.0f)
                .compensationCompletionRate(80)
                .patterns(MissedWorkoutReportResponse.MissedWorkoutPatterns.builder()
                        .byDayOfWeek(byDayOfWeek)
                        .byReason(byReason)
                        .mostMissedDay("Monday")
                        .mostCommonReason("TOO_BUSY")
                        .build())
                .recommendations(List.of("Consider lighter workouts on Mondays"))
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/missed-workouts")
    class GetMissedWorkoutsTests {

        @Test
        @DisplayName("Should return paginated missed workouts")
        void getMissedWorkouts_Success() throws Exception {
            Page<MissedWorkoutResponse> page = new PageImpl<>(
                    List.of(mockMissedWorkoutResponse),
                    PageRequest.of(0, 20),
                    1
            );

            when(missedWorkoutService.getMissedWorkouts(eq(1L), any())).thenReturn(page);

            mockMvc.perform(get("/api/v1/missed-workouts")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray())
                    .andExpect(jsonPath("$.data.totalElements").value(1));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/missed-workouts/unaddressed")
    class GetUnaddressedMissedWorkoutsTests {

        @Test
        @DisplayName("Should return unaddressed missed workouts")
        void getUnaddressedMissedWorkouts_Success() throws Exception {
            when(missedWorkoutService.getUnaddressedMissedWorkouts(1L))
                    .thenReturn(List.of(mockMissedWorkoutResponse));

            mockMvc.perform(get("/api/v1/missed-workouts/unaddressed")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data[0].isReplanned").value(false));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/missed-workouts/{id}/makeup-options")
    class GetMakeupOptionsTests {

        @Test
        @DisplayName("Should return makeup options")
        void getMakeupOptions_Success() throws Exception {
            List<MakeupWorkoutOptionResponse> options = List.of(
                    mockMakeupOption,
                    MakeupWorkoutOptionResponse.builder()
                            .option(MakeupOption.EXTEND_PROGRAM)
                            .description("Extend program by one week")
                            .build()
            );

            when(missedWorkoutService.generateMakeupOptions(1L, 1L)).thenReturn(options);

            mockMvc.perform(get("/api/v1/missed-workouts/1/makeup-options")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray())
                    .andExpect(jsonPath("$.data.length()").value(2));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/missed-workouts/{id}/makeup")
    class SelectMakeupOptionTests {

        @Test
        @DisplayName("Should select makeup option successfully")
        void selectMakeupOption_Success() throws Exception {
            SelectMakeupOptionRequest request = SelectMakeupOptionRequest.builder()
                    .selectedOption(MakeupOption.RESCHEDULE_NEXT_DAY)
                    .build();

            MissedWorkoutResponse replannedResponse = MissedWorkoutResponse.builder()
                    .missedWorkoutId(1L)
                    .sessionName("Push Day")
                    .isReplanned(true)
                    .replanStrategy("RESCHEDULE_NEXT_DAY")
                    .build();

            when(missedWorkoutService.selectMakeupOption(eq(1L), eq(1L), any(SelectMakeupOptionRequest.class)))
                    .thenReturn(replannedResponse);

            mockMvc.perform(post("/api/v1/missed-workouts/1/makeup")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.isReplanned").value(true))
                    .andExpect(jsonPath("$.data.replanStrategy").value("RESCHEDULE_NEXT_DAY"));
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/missed-workouts/{id}/reschedule")
    class RescheduleTests {

        @Test
        @DisplayName("Should reschedule missed workout successfully")
        void rescheduleMissedWorkout_Success() throws Exception {
            RescheduleMissedWorkoutRequest request = RescheduleMissedWorkoutRequest.builder()
                    .newDate(LocalDate.now().plusDays(3))
                    .notes("Rescheduled to Saturday")
                    .build();

            MissedWorkoutResponse rescheduledResponse = MissedWorkoutResponse.builder()
                    .missedWorkoutId(1L)
                    .sessionName("Push Day")
                    .isReplanned(true)
                    .replanStrategy("MANUAL_RESCHEDULE")
                    .build();

            when(missedWorkoutService.rescheduleMissedWorkout(eq(1L), eq(1L), any(RescheduleMissedWorkoutRequest.class)))
                    .thenReturn(rescheduledResponse);

            mockMvc.perform(put("/api/v1/missed-workouts/1/reschedule")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.replanStrategy").value("MANUAL_RESCHEDULE"));
        }

        @Test
        @DisplayName("Should return 400 when new date is not in the future")
        void rescheduleMissedWorkout_PastDate_ReturnsBadRequest() throws Exception {
            RescheduleMissedWorkoutRequest request = RescheduleMissedWorkoutRequest.builder()
                    .newDate(LocalDate.now())  // Today is not @Future
                    .build();

            mockMvc.perform(put("/api/v1/missed-workouts/1/reschedule")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/missed-workouts/report")
    class GetReportTests {

        @Test
        @DisplayName("Should return missed workout report")
        void getMissedWorkoutReport_Success() throws Exception {
            when(missedWorkoutService.getMissedWorkoutReport(eq(1L), any(), any()))
                    .thenReturn(mockReport);

            mockMvc.perform(get("/api/v1/missed-workouts/report")
                            .with(jwt().jwt(j -> j.subject("1")))
                            .param("startDate", LocalDate.now().minusDays(30).toString())
                            .param("endDate", LocalDate.now().toString()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.totalMissedWorkouts").value(5))
                    .andExpect(jsonPath("$.data.adherencePercentage").value(75.0))
                    .andExpect(jsonPath("$.data.patterns.mostMissedDay").value("Monday"))
                    .andExpect(jsonPath("$.data.recommendations").isArray());
        }

        @Test
        @DisplayName("Should work without date parameters")
        void getMissedWorkoutReport_NoDates_Success() throws Exception {
            when(missedWorkoutService.getMissedWorkoutReport(eq(1L), eq(null), eq(null)))
                    .thenReturn(mockReport);

            mockMvc.perform(get("/api/v1/missed-workouts/report")
                            .with(jwt().jwt(j -> j.subject("1"))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }
}
