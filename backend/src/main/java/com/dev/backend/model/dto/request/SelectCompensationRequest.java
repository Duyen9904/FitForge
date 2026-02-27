package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.CompensationType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Request DTO for selecting a compensation option (UC-7.4, UC-11.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SelectCompensationRequest {

    @NotNull(message = "Compensation type is required")
    private CompensationType compensationType;
    
    private LocalDate preferredDate; // User preferred date for the compensation
    
    private String notes; // Optional user notes
}

