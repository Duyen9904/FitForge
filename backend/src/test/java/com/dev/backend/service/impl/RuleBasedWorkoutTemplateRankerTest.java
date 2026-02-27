package com.dev.backend.service.impl;

import com.dev.backend.model.dto.profile.UserProfile;
import com.dev.backend.model.entity.WorkoutTemplate;
import com.dev.backend.repository.WorkoutTemplateRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RuleBasedWorkoutTemplateRankerTest {

    @Mock
    private WorkoutTemplateRepository templateRepository;

    @InjectMocks
    private RuleBasedWorkoutTemplateRanker ranker;

    private UserProfile buildProfile() {
        return UserProfile.builder()
                .userId(123L)
                .primaryGoalName("Build Muscle")
                .fitnessLevel("BEGINNER")
                .scheduleDays(List.of("MON", "WED", "FRI"))
                .equipmentKeys(List.of("DUMBBELLS", "BARBELL"))
                .healthLimitations(List.of("LOWER_BACK_PAIN"))
                .build();
    }

    private WorkoutTemplate template(String name, String goalType, String experience, Integer daysPerWeek,
                                     String equipmentTags, String contraindications) {
        WorkoutTemplate t = new WorkoutTemplate();
        t.setTemplateId((long) name.hashCode());
        t.setName(name);
        t.setGoalType(goalType);
        t.setExperienceLevel(experience);
        t.setDaysPerWeek(daysPerWeek);
        t.setEquipmentTags(equipmentTags);
        t.setContraindications(contraindications);
        return t;
    }

    @Nested
    @DisplayName("rankTemplatesForUser")
    class RankTemplatesForUserTests {

        @Test
        @DisplayName("Should return templates ordered by score and filter out unsafe ones")
        void rankTemplatesForUser_OrdersAndFilters() {
            UserProfile profile = buildProfile();

            WorkoutTemplate highScore = template(
                    "High Score",
                    "MUSCLE_GAIN",
                    "BEGINNER",
                    3,
                    "DUMBBELLS,BARBELL",
                    null
            );

            WorkoutTemplate lowerScore = template(
                    "Lower Score",
                    "ENDURANCE",
                    "INTERMEDIATE",
                    2,
                    "DUMBBELLS",
                    null
            );

            // This one should be disqualified because of contraindication
            WorkoutTemplate unsafe = template(
                    "Unsafe",
                    "MUSCLE_GAIN",
                    "BEGINNER",
                    3,
                    "DUMBBELLS,BARBELL",
                    "LOWER_BACK_PAIN"
            );

            when(templateRepository.findByIsActiveTrueOrderByNameAsc())
                    .thenReturn(List.of(highScore, lowerScore, unsafe));

            List<WorkoutTemplate> result = ranker.rankTemplatesForUser(profile, 10);

            assertThat(result)
                    .hasSize(2)
                    .containsExactly(highScore, lowerScore);
        }
    }

    @Nested
    @DisplayName("explainRecommendation")
    class ExplainRecommendationTests {

        @Test
        @DisplayName("Should include detailed reasons when attributes match")
        void explainRecommendation_IncludesReasons() {
            UserProfile profile = buildProfile();

            WorkoutTemplate template = template(
                    "Matched Template",
                    "MUSCLE_GAIN",
                    "BEGINNER",
                    3,
                    "DUMBBELLS,BARBELL",
                    null
            );

            String explanation = ranker.explainRecommendation(template, profile);

            assertThat(explanation).contains("Matches your Build Muscle goal");
            assertThat(explanation).contains("Designed for beginner level");
            assertThat(explanation).contains("Fits your 3 days/week schedule");
            assertThat(explanation).contains("Compatible with your available equipment");
        }

        @Test
        @DisplayName("Should fall back to generic explanation when nothing matches")
        void explainRecommendation_GenericWhenNoMatches() {
            UserProfile profile = UserProfile.builder()
                    .userId(123L)
                    .primaryGoalName("Lose Fat")
                    .fitnessLevel("ADVANCED")
                    .scheduleDays(List.of("MON"))
                    .equipmentKeys(List.of())
                    .healthLimitations(List.of())
                    .build();

            WorkoutTemplate template = template(
                    "Unrelated",
                    "STRENGTH",
                    "BEGINNER",
                    5,
                    "BARBELL",
                    null
            );

            String explanation = ranker.explainRecommendation(template, profile);

            assertThat(explanation).contains("Recommended based on your fitness profile");
        }
    }
}

