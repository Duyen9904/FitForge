package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for cheat meal log (UC-7.3)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CheatMealLogResponse {

    private Long cheatMealLogId;
    private Long planMealId;
    private LocalDate cheatDate;
    private String mealName;
    private Integer mealCalories;
    private Integer excessCalories;
    private String compensationStrategy;
    private Boolean isCompensated;
}
