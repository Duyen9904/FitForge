package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "nutrition_adjustment")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class NutritionAdjustment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long adjustmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_plan_id", nullable = false)
    private NutritionPlan nutritionPlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "compensation_action_id")
    private CompensationAction compensationAction;

    @Column(nullable = false)
    private LocalDate adjustmentDate;

    private LocalDate validUntilDate;

    private Integer calorieAdjustment;

    @Column(length = 500)
    private String adjustmentReason;

    @Column(length = 1000)
    private String mealRecommendations;

    @Column(nullable = false)
    private Boolean isActive = true;
}
