package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

/**
 * Entity for storing user's measurement goals (UC-8.3)
 */
@Entity
@Table(
    name = "measurement_goal",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_measurement_goal_user", columnNames = "user_id")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class MeasurementGoal extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long goalId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    private Float targetWeightKg;

    private Float targetBodyFatPercentage;

    private Float targetChestCm;

    private Float targetWaistCm;

    private Float targetHipsCm;

    private Float targetBicepsCm;

    private Float targetThighsCm;

    private LocalDate targetDate;

    @Column(nullable = false)
    private Boolean isActive = true;

    @Column(length = 500)
    private String notes;
}
