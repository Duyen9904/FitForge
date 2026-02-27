package com.dev.backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "nutrition_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class NutritionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long nutritionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate logDate;

    @Column(length = 50)
    private String mealType;

    @Column(nullable = false, length = 200)
    private String foodName;

    private Integer calories;

    private Float proteinG;

    private Float carbsG;

    private Float fatsG;

    private Instant mealTime;

    @Column(nullable = false)
    private Boolean isCheatMeal = false;

    /**
     * Optional adherence score for this log entry (0.0 - 1.0),
     * comparing this meal to the user's current nutrition plan.
     * This can be populated by analytics jobs or adjustment logic.
     */
    private Float adherenceScore;

    /**
     * Source of the log, e.g. "MANUAL", "TEMPLATE", "INTEGRATION".
     */
    @Column(length = 50)
    private String source;

    @Column(length = 500)
    private String notes;

    @OneToOne(mappedBy = "nutritionLog", cascade = CascadeType.ALL, orphanRemoval = true)
    private CheatMealLog cheatMealLog;
}
