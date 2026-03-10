package com.dev.backend.model.entity;

import com.dev.backend.model.enums.MealType;
import com.dev.backend.model.enums.PlanMealSource;
import com.dev.backend.model.enums.PlanMealStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Unified meal entity representing both planned meals (from templates)
 * Unified entity handling both planned meals (from templates)
 *
 * - mealTemplate != null → planned meal from a template
 * - mealTemplate == null → free-form logged meal (user-entered data)
 */
@Entity
@Table(
    name = "plan_meal",
    indexes = {
        @Index(name = "idx_plan_meal_user_date", columnList = "user_id, scheduled_date"),
        @Index(name = "idx_plan_meal_plan_date", columnList = "nutrition_plan_id, scheduled_date"),
        @Index(name = "idx_plan_meal_status", columnList = "status")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
public class PlanMeal extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long planMealId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_plan_id")
    private NutritionPlan nutritionPlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meal_template_id")
    private MealTemplate mealTemplate;

    @Column(nullable = false)
    private LocalDate scheduledDate;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private MealType mealType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PlanMealStatus status = PlanMealStatus.PLANNED;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PlanMealSource source = PlanMealSource.MANUAL;

    // Denormalized meal data — copied from template or entered manually
    @Column(nullable = false, length = 200)
    private String foodName;

    private Integer calories;

    private Float proteinG;

    private Float carbsG;

    private Float fatsG;

    private Instant mealTime;

    private Instant completedAt;

    @Column(nullable = false)
    private Boolean isCheatMeal = false;

    /**
     * Optional adherence score (0.0 - 1.0),
     * comparing this meal to the nutrition plan targets.
     */
    private Float adherenceScore;

    @Column(length = 500)
    private String notes;

    @OneToOne(mappedBy = "planMeal", cascade = CascadeType.ALL, orphanRemoval = true)
    private CheatMealLog cheatMealLog;
}
