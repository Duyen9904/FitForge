package com.dev.backend.model.entity;

import com.dev.backend.model.enums.MealTemplateSource;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "meal_template")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class MealTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long mealTemplateId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nutrition_plan_id")
    private NutritionPlan nutritionPlan;

    /**
     * Owner of this template. Null for system-provided templates.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    /**
     * Whether this template was created by the system or a user.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private MealTemplateSource source = MealTemplateSource.SYSTEM;

    @Column(nullable = false, length = 100)
    private String mealName;

    @Column(length = 50)
    private String mealType;

    @Column(length = 500)
    private String description;

    private Integer calories;

    private Float proteinG;

    private Float carbsG;

    private Float fatsG;

    @Column(length = 2000)
    private String recipeInstructions;
}
