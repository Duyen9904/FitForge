package com.dev.backend.model.dto.response;

import com.dev.backend.model.enums.MakeupOption;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Response DTO for makeup workout options (UC-6.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MakeupWorkoutOptionResponse {

    private MakeupOption option;
    private String description;
    private String detailedExplanation;
    private List<LocalDate> affectedDates;
    private Integer estimatedRecoveryDays;
    private String recommendation;
}
