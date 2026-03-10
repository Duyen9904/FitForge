package com.dev.backend.model.dto.ai;

import com.dev.backend.model.dto.profile.UserProfile;
import lombok.Builder;
import lombok.Value;

/**
 * Context DTO encapsulating all inputs needed by AiService
 * to generate or adjust a nutrition plan.
 */
@Value
@Builder
public class AiNutritionPlanContext {
    UserProfile profile;
    String goalName;
    String dietaryPreferences;    // e.g. "vegetarian", "vegan", "keto"
    String dietaryRestrictions;   // e.g. "gluten-free", "nut allergy"
    String additionalNotes;

    // For adjustments only
    String currentPlanName;
    Integer currentDailyCalorieTarget;
    Float currentProteinPercentage;
    Float currentCarbsPercentage;
    Float currentFatsPercentage;
    Float nutritionAdherence;      // 0.0-1.0 (logged days / total days)
    Float avgCalorieIntake;        // average daily calories over last week
    String weightTrend;            // e.g. "LOSING", "GAINING", "STABLE"
}
