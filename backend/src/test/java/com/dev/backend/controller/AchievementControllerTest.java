package com.dev.backend.controller;

import com.dev.backend.model.dto.request.ShareAchievementRequest;
import com.dev.backend.model.dto.response.*;
import com.dev.backend.service.AchievementService;
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

import java.time.Instant;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AchievementController.class)
class AchievementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AchievementService achievementService;

    private AchievementResponse mockAchievement;
    private UserAchievementResponse mockUserAchievement;
    private AchievementGalleryResponse mockGallery;
    private ShareAchievementResponse mockShareResponse;

    @BeforeEach
    void setUp() {
        mockAchievement = AchievementResponse.builder()
                .achievementId(1L)
                .achievementName("First Workout")
                .description("Complete your first workout")
                .points(100)
                .category("WORKOUT")
                .isEarned(false)
                .progressPercent(0.0)
                .build();

        mockUserAchievement = UserAchievementResponse.builder()
                .userAchievementId(1L)
                .achievementId(1L)
                .achievementName("First Workout")
                .points(100)
                .category("WORKOUT")
                .earnedDate(Instant.now())
                .isDisplayed(true)
                .build();

        mockGallery = AchievementGalleryResponse.builder()
                .earnedAchievements(Arrays.asList(mockUserAchievement))
                .earnedCount(1)
                .lockedAchievements(Arrays.asList(mockAchievement))
                .lockedCount(1)
                .totalAchievements(2)
                .totalPoints(100)
                .completionPercent(50.0)
                .build();

        mockShareResponse = ShareAchievementResponse.builder()
                .success(true)
                .shareableLink("https://gymplan.app/share/achievement/1")
                .platform("twitter")
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/achievements")
    class GetAllAchievementsTests {

        @Test
        @DisplayName("Should get all achievements")
        void getAllAchievements_Success() throws Exception {
            List<AchievementResponse> achievements = Arrays.asList(mockAchievement);
            when(achievementService.getAllAchievements()).thenReturn(achievements);

            mockMvc.perform(get("/api/v1/achievements")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getAllAchievements();
        }

        @Test
        @DisplayName("Should return 401 when not authenticated")
        void getAllAchievements_NoAuth_ReturnsUnauthorized() throws Exception {
            mockMvc.perform(get("/api/v1/achievements"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/achievements/gallery")
    class GetGalleryTests {

        @Test
        @DisplayName("Should get achievement gallery")
        void getGallery_Success() throws Exception {
            when(achievementService.getAchievementGallery(anyLong())).thenReturn(mockGallery);

            mockMvc.perform(get("/api/v1/achievements/gallery")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getAchievementGallery(1L);
        }
    }

    @Nested
    @DisplayName("GET /api/v1/achievements/earned")
    class GetEarnedAchievementsTests {

        @Test
        @DisplayName("Should get earned achievements")
        void getEarnedAchievements_Success() throws Exception {
            List<UserAchievementResponse> earned = Arrays.asList(mockUserAchievement);
            when(achievementService.getEarnedAchievements(anyLong())).thenReturn(earned);

            mockMvc.perform(get("/api/v1/achievements/earned")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getEarnedAchievements(1L);
        }
    }

    @Nested
    @DisplayName("GET /api/v1/achievements/category/{category}")
    class GetByCategoryTests {

        @Test
        @DisplayName("Should get achievements by category")
        void getByCategory_Success() throws Exception {
            List<AchievementResponse> achievements = Arrays.asList(mockAchievement);
            when(achievementService.getAchievementsByCategory(anyLong(), anyString())).thenReturn(achievements);

            mockMvc.perform(get("/api/v1/achievements/category/WORKOUT")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getAchievementsByCategory(1L, "WORKOUT");
        }
    }

    @Nested
    @DisplayName("GET /api/v1/achievements/points")
    class GetTotalPointsTests {

        @Test
        @DisplayName("Should get total points")
        void getTotalPoints_Success() throws Exception {
            when(achievementService.getTotalPoints(anyLong())).thenReturn(500);

            mockMvc.perform(get("/api/v1/achievements/points")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getTotalPoints(1L);
        }
    }

    @Nested
    @DisplayName("POST /api/v1/achievements/{achievementId}/share")
    class ShareAchievementTests {

        @Test
        @DisplayName("Should share achievement successfully")
        void shareAchievement_Success() throws Exception {
            ShareAchievementRequest request = ShareAchievementRequest.builder()
                    .platform("twitter")
                    .customMessage("I did it!")
                    .build();

            when(achievementService.shareAchievement(anyLong(), anyLong(), any(ShareAchievementRequest.class)))
                    .thenReturn(mockShareResponse);

            mockMvc.perform(post("/api/v1/achievements/1/share")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).shareAchievement(eq(1L), eq(1L), any(ShareAchievementRequest.class));
        }

        @Test
        @DisplayName("Should return 400 when platform is blank")
        void shareAchievement_BlankPlatform_ReturnsBadRequest() throws Exception {
            ShareAchievementRequest invalidRequest = ShareAchievementRequest.builder()
                    .platform("")
                    .build();

            mockMvc.perform(post("/api/v1/achievements/1/share")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidRequest)))
                    .andExpect(status().isBadRequest());

            verify(achievementService, never()).shareAchievement(anyLong(), anyLong(), any());
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/achievements/{achievementId}/display")
    class ToggleDisplayTests {

        @Test
        @DisplayName("Should toggle achievement display")
        void toggleDisplay_Success() throws Exception {
            UserAchievementResponse toggled = UserAchievementResponse.builder()
                    .userAchievementId(1L)
                    .achievementId(1L)
                    .isDisplayed(false)
                    .build();

            when(achievementService.toggleAchievementDisplay(anyLong(), anyLong(), anyBoolean()))
                    .thenReturn(toggled);

            mockMvc.perform(put("/api/v1/achievements/1/display")
                            .with(jwt().jwt(jwt -> jwt.subject("1")))
                            .with(csrf())
                            .param("display", "false"))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).toggleAchievementDisplay(1L, 1L, false);
        }
    }

    @Nested
    @DisplayName("GET /api/v1/achievements/{achievementId}/progress")
    class GetProgressTests {

        @Test
        @DisplayName("Should get achievement progress")
        void getProgress_Success() throws Exception {
            AchievementResponse progressResponse = AchievementResponse.builder()
                    .achievementId(2L)
                    .progressPercent(25.0)
                    .build();

            when(achievementService.getAchievementProgress(anyLong(), anyLong()))
                    .thenReturn(progressResponse);

            mockMvc.perform(get("/api/v1/achievements/2/progress")
                            .with(jwt().jwt(jwt -> jwt.subject("1"))))
                    .andExpect(status().isOk());

            verify(achievementService, times(1)).getAchievementProgress(1L, 2L);
        }
    }
}
