package com.dev.backend.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating a goal template (UC-16.2)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateGoalRequest {

    @NotBlank(message = "Goal name is required")
    @Size(max = 100, message = "Goal name must be at most 100 characters")
    private String goalName;

    @Size(max = 500, message = "Description must be at most 500 characters")
    private String description;
}
