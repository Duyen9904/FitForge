package com.dev.backend.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountSummaryDto {

    private Long userId;

    private String username;
    private String email;

    private LocalDate dateOfBirth;
    private String gender;

    private Float heightCm;
    private Float currentWeightKg;
    private Float targetWeightKg;

    private String fitnessLevel;

    private String profileImageUrl;

    private String role;

    private LocalDate dateJoined;
}