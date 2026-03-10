package com.dev.backend.model.entity;

import com.dev.backend.model.enums.MealType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(
    name = "day_meal",
    indexes = {
        @Index(name = "idx_day_meal_day", columnList = "nutrition_day_id")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class DayMeal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long dayMealId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_day_id", nullable = false)
    private NutritionDay nutritionDay;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meal_template_id", nullable = false)
    private MealTemplate mealTemplate;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private MealType mealType;

    @Column(nullable = false)
    private Integer orderIndex;

    /**
     * Optional calorie/macro overrides (e.g. half portion).
     * If null, use values from mealTemplate.
     */
    private Integer customCalories;
    private Float customProteinG;
    private Float customCarbsG;
    private Float customFatsG;

    @Column(length = 500)
    private String notes;

    /** Optional GCS object path for proof photo uploaded on meal completion */
    @Column(length = 500)
    private String proofPhotoUrl;

    private Instant completedAt;
}
