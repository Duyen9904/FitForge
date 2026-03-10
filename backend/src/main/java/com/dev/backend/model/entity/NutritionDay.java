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
    name = "nutrition_day",
    indexes = {
        @Index(name = "idx_nutrition_day_plan", columnList = "nutrition_plan_id"),
        @Index(name = "idx_nutrition_day_plan_day", columnList = "nutrition_plan_id, day_number")
    },
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_nutrition_day_plan_day", columnNames = {"nutrition_plan_id", "day_number"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class NutritionDay {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long nutritionDayId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_plan_id", nullable = false)
    private NutritionPlan nutritionPlan;

    @Column(nullable = false)
    private Integer dayNumber;

    @Column(length = 100)
    private String dayName;

    @Column(length = 500)
    private String description;

    /**
     * Optional day-specific calorie target.
     * If null, inherits from NutritionPlan.dailyCalorieTarget.
     */
    private Integer targetCalories;

    @Column(nullable = false)
    private Boolean isRestDay = false;

    @OneToMany(mappedBy = "nutritionDay", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("orderIndex ASC")
    private List<DayMeal> dayMeals = new ArrayList<>();
}
