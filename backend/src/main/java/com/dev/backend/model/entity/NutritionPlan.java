package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "nutrition_plan",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_nutrition_plan_user", columnNames = "user_id")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class NutritionPlan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long nutritionPlanId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id")
    private Goal goal;

    @Column(nullable = false, length = 100)
    private String planName;

    private Integer dailyCalorieTarget;

    private Float proteinPercentage;

    private Float carbsPercentage;

    private Float fatsPercentage;

    private Integer cheatMealsPerWeek;

    /**
     * Indicates which algorithm generated or last adjusted this plan.
     * Example values: "RULE_BASED_V1", "AI_V1".
     */
    @Column(length = 50)
    private String algorithmVersion;

    /**
     * Semantic version of the plan. Incremented whenever the system
     * applies an automatic nutrition adjustment.
     */
    @Column(nullable = false)
    private Integer version = 1;

    /**
     * Short human-readable explanation of why this plan was generated
     * or last adjusted (e.g. weekly adherence off-target).
     */
    @Column(length = 500)
    private String recommendationReason;

    @Column(nullable = false)
    private Boolean autoAdjustEnabled = false;

    @Column(nullable = false)
    private Boolean isActive = true;


    @OneToMany(mappedBy = "nutritionPlan", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<NutritionAdjustment> nutritionAdjustments = new ArrayList<>();
}
