package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for a day within a nutrition plan.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionDayResponse {

    private Long nutritionDayId;
    private Integer dayNumber;
    private String dayName;
    private String description;
    private Integer targetCalories;
    private Boolean isRestDay;
    private List<DayMealResponse> meals;
}
