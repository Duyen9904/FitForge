package com.dev.backend.model.dto.request;

import com.dev.backend.model.enums.MakeupOption;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for selecting a makeup workout option (UC-6.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SelectMakeupOptionRequest {

    @NotNull(message = "Makeup option is required")
    private MakeupOption selectedOption;
}
